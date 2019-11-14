resource "aws_key_pair" "femiwiki" {
  key_name   = "femiwiki-2018-09-15"
  public_key = file("res/femiwiki_rsa.pub")
}

data "aws_ami" "femiwiki_base" {
  most_recent = true
  name_regex  = "^femiwiki-base \\d{4}-\\d{2}-\\d{2} \\d{2}_\\d{2}$"
  owners      = ["self"]
}

resource "aws_instance" "femiwiki" {
  ebs_optimized           = true
  ami                     = data.aws_ami.femiwiki_base.image_id
  instance_type           = "t3a.micro"
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
    iops                  = 0
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

  user_data = <<EOF
#!/bin/bash
set -euo pipefail; IFS=$'\n\t'

# Enable verbose mode
set -x

sudo -u ec2-user git clone https://github.com/femiwiki/docker-mediawiki.git /home/ec2-user/mediawiki/
# TODO: Download seceret from S3
# TODO: Download database dump from S3
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
