# TODO: 없앨 예정
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
data "aws_ami" "femiwiki_base" {
  most_recent = true
  name_regex  = "^femiwiki-base \\d{4}-\\d{2}-\\d{2} \\d{2}_\\d{2}$"
  owners      = ["self"]
}

data "aws_ami" "amazon_linux_2" {
  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-minimal-hvm-2.0.*-x86_64-ebs"]
  }

  filter {
    name   = "ena-support"
    values = ["true"]
  }

  # 이 AMI로 고정함
  name_regex = "^amzn2-ami-minimal-hvm-2.0.20191116.0-x86_64-ebs$"
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
    Name = "femiwiki (old)"
  }

  volume_tags = {
    Name = "femiwiki"
  }

  user_data = <<EOF
#!/bin/bash
set -euo pipefail; IFS=$'\n\t'

# Enable verbose mode
set -x

sudo -u ec2-user git clone https://github.com/femiwiki/docker-mediawiki.git /home/ec2-user/mediawiki/
# TODO: Download seceret from somewhere (https://github.com/femiwiki/femiwiki/issues/110)
# TODO: Download database dump from S3 to /srv/mysql/
# TODO: Place/touch restbase database at /srv/restbase.sqlite3
sudo -u ec2-user cp /home/ec2-user/mediawiki/configs/secret.php.example /home/ec2-user/mediawiki/configs/secret.php
sudo -u ec2-user cp /home/ec2-user/mediawiki/configs/bot-secret.sample.env /home/ec2-user/mediawiki/configs/bot-secret.env
docker swarm init
# docker stack deploy --prune -c /home/ec2-user/mediawiki/production.yml mediawiki
# docker stack deploy --prune -c /home/ec2-user/database/bots.yml botse
EOF

  lifecycle {
    ignore_changes = [
      ami,
      user_data,
    ]
  }
}

resource "aws_eip" "femiwiki" {
  instance = aws_instance.femiwiki.id
  vpc      = true
}

resource "aws_instance" "femiwiki_green" {
  ebs_optimized           = true
  ami                     = data.aws_ami.amazon_linux_2.image_id
  instance_type           = "t3a.small"
  key_name                = aws_key_pair.femiwiki_green.key_name
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
    volume_size           = 16
    volume_type           = "gp2"
  }

  credit_specification {
    cpu_credits = "unlimited"
  }

  tags = {
    Name = "femiwiki"
  }

  volume_tags = {
    Name = "femiwiki"
  }

  user_data = file("res/bootstrap.sh")

  lifecycle {
    ignore_changes = [
      ami,
      user_data,
    ]
  }
}

resource "aws_eip" "femiwiki_green" {
  instance = aws_instance.femiwiki_green.id
  vpc      = true
}

resource "aws_ebs_volume" "persistent_data" {
  availability_zone = aws_instance.femiwiki_green.availability_zone
  size              = 4
  tags = {
    Name = "Persistent data"
  }
}
