# TODO: 없앨 예정
# https://github.com/femiwiki/femiwiki/issues/132
resource "aws_key_pair" "femiwiki" {
  key_name   = "femiwiki-2018-09-15"
  public_key = file("res/femiwiki_rsa.pub")
}

# 김지현이 소지하고있는 비상용 키페어
resource "aws_key_pair" "femiwiki_green" {
  key_name   = "femiwiki-emergency-key"
  public_key = file("res/femiwiki_rsa_green.pub")
}

# TODO: 없앨 예정
resource "aws_instance" "femiwiki" {
  ebs_optimized           = true
  ami                     = data.aws_ami.femiwiki_base.image_id
  instance_type           = "t3a.small"
  key_name                = aws_key_pair.femiwiki.key_name
  monitoring              = false
  iam_instance_profile    = aws_iam_instance_profile.femiwiki.name
  disable_api_termination = true

  vpc_security_group_ids = [
    aws_default_security_group.default.id,
    aws_security_group.femiwiki.id,
  ]

  root_block_device {
    delete_on_termination = true
    encrypted             = false
    volume_size           = 24
    volume_type           = "gp2"
  }

  credit_specification {
    cpu_credits = "unlimited"
  }

  tags = {
    Name = "main server"
  }

  volume_tags = {
    Name = "main server"
  }

  user_data = <<EOF
#!/bin/bash
set -euo pipefail; IFS=$'\n\t'

# Enable verbose mode
set -x

yum install amazon-cloudwatch-agent
cat <<'CONFIG' > /opt/aws/amazon-cloudwatch-agent/bin/config.json
{
  "metrics": {
    "metrics_collected": {
      "disk": {
        "measurement": [
          "used_percent"
        ],
        "resources": [
          "/"
        ]
      },
      "mem": {
        "measurement": [
          "mem_used_percent"
        ]
      }
    }
  }
}
CONFIG
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json

sudo -u ec2-user git clone https://github.com/femiwiki/docker-mediawiki.git /home/ec2-user/mediawiki/
# TODO: Download seceret from somewhere (https://github.com/femiwiki/femiwiki/issues/110)
# TODO: Download database dump from S3 to /srv/mysql/
# TODO: Place/touch restbase database at /srv/restbase.sqlite3
sudo -u ec2-user cp /home/ec2-user/mediawiki/configs/secret.php.example /home/ec2-user/mediawiki/configs/secret.php
sudo -u ec2-user cp /home/ec2-user/mediawiki/configs/bot-secret.sample.env /home/ec2-user/mediawiki/configs/bot-secret.env
docker swarm init
# docker stack deploy --prune -c /home/ec2-user/mediawiki/production.yml mediawiki
# docker stack deploy --prune -c /home/ec2-user/database/bots.yml bots
EOF

  lifecycle {
    ignore_changes = [
      ami,
      user_data,
    ]
  }
}

# Interchanched temporarily
# TODO fix after closing https://github.com/femiwiki/femiwiki/issues/116
resource "aws_eip" "femiwiki" {
  instance = aws_instance.femiwiki_green.id
  vpc      = true
}

#
# Exprimental Nomad server
#

resource "aws_instance" "femiwiki_green" {
  ebs_optimized           = true
  ami                     = data.aws_ami.amazon_linux_2.image_id
  instance_type           = "t3a.small"
  key_name                = aws_key_pair.femiwiki_green.key_name
  monitoring              = false
  iam_instance_profile    = aws_iam_instance_profile.femiwiki.name
  disable_api_termination = true
  availability_zone       = aws_ebs_volume.persistent_data.availability_zone

  vpc_security_group_ids = [
    aws_default_security_group.default.id,
    aws_security_group.femiwiki.id,
  ]

  root_block_device {
    delete_on_termination = true
    # required for enabling hibernation
    # https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/Hibernate.html#hibernating-prerequisites
    encrypted   = true
    volume_size = 16
    volume_type = "gp2"
  }

  credit_specification {
    cpu_credits = "unlimited"
  }

  tags = {
    Name = "experimental nomad server"
  }

  volume_tags = {
    Name = "experimental nomad server"
  }

  user_data = file("res/bootstrap.sh")

  lifecycle {
    ignore_changes = [
      ami,
      user_data,
    ]
  }
}

# Interchanched temporarily
# TODO fix after closing https://github.com/femiwiki/femiwiki/issues/116
resource "aws_eip" "femiwiki_green" {
  instance = aws_instance.femiwiki.id
  vpc      = true
}

resource "aws_ebs_volume" "persistent_data" {
  availability_zone = "ap-northeast-1a"
  size              = 8
  tags = {
    Name = "experimental nomad server"
  }
}

resource "aws_volume_attachment" "persistent_data" {
  device_name = "/dev/xvdf"
  volume_id   = aws_ebs_volume.persistent_data.id
  instance_id = aws_instance.femiwiki_green.id
}

#
# Exprimental arm64 server
#

data "aws_availability_zone" "femiwiki_arm64" {
  name = "ap-northeast-1a"
}

resource "aws_instance" "femiwiki_arm64" {
  ebs_optimized           = true
  ami                     = data.aws_ami.amazon_linux_2_arm64.image_id
  instance_type           = "t4g.micro"
  key_name                = aws_key_pair.femiwiki.key_name
  monitoring              = false
  iam_instance_profile    = aws_iam_instance_profile.femiwiki.name
  disable_api_termination = true
  availability_zone       = data.aws_availability_zone.femiwiki_arm64.name

  vpc_security_group_ids = [
    aws_default_security_group.default.id,
    aws_security_group.femiwiki.id,
  ]

  root_block_device {
    delete_on_termination = true
    volume_size           = 16
    volume_type           = "gp2"
  }

  credit_specification {
    cpu_credits = "unlimited"
  }

  tags = {
    Name = "experimental arm64 server"
  }

  volume_tags = {
    Name = "experimental arm64 server"
  }

  user_data = file("res/bootstrap.sh")

  lifecycle {
    ignore_changes = [
      ami,
      user_data,
    ]
  }
}

resource "aws_ebs_volume" "persistent_data_mysql" {
  availability_zone = data.aws_availability_zone.femiwiki_arm64.name
  size              = 8
  tags = {
    Name = "mysql for experimental arm64 server"
  }
}

resource "aws_ebs_volume" "persistent_data_caddycert" {
  availability_zone = data.aws_availability_zone.femiwiki_arm64.name
  size              = 1
  tags = {
    Name = "caddycert for experimental arm64 server"
  }
}

resource "aws_ebs_volume" "persistent_data_secrets" {
  availability_zone = data.aws_availability_zone.femiwiki_arm64.name
  size              = 1
  tags = {
    Name = "secrets for experimental arm64 server"
  }
}

resource "aws_eip" "femiwiki_arm64" {
  instance = aws_instance.femiwiki_arm64.id
  vpc      = true
}
