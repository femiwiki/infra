resource "aws_key_pair" "femiwiki" {
  key_name   = "femiwiki-2018-09-15"
  public_key = file("res/femiwiki_rsa.pub")
}

# TODO: base launch template은 별 쓸모가 없다. DB용 launch template로 바꾸자.
resource "aws_launch_template" "base" {
  name        = "base"
  description = "Base Launch Template"

  disable_api_termination              = true
  ebs_optimized                        = true
  image_id                             = "ami-0019c8208fd95e551"
  instance_initiated_shutdown_behavior = "stop"
  instance_type                        = "t3.nano"
  key_name                             = aws_key_pair.femiwiki.key_name
  vpc_security_group_ids               = [aws_default_security_group.default.id, aws_security_group.mediawiki.id]

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      delete_on_termination = false
      snapshot_id           = "snap-0de1ef9e4ea75d3a0"
      volume_size           = 16
      volume_type           = "gp2"
    }
  }

  iam_instance_profile {
    arn = aws_iam_instance_profile.mediawiki.arn
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "database+bots"
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      Name = "database+bots"
    }
  }
}

resource "aws_launch_template" "mediawiki" {
  name        = "mediawiki"
  description = "A launch template for mediawiki servers"

  disable_api_termination              = true
  ebs_optimized                        = true
  image_id                             = "ami-0a20c8152821c73ba"
  instance_initiated_shutdown_behavior = "terminate"
  instance_type                        = "t3.micro"
  key_name                             = aws_key_pair.femiwiki.key_name
  vpc_security_group_ids               = [aws_default_security_group.default.id, aws_security_group.mediawiki.id]

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      delete_on_termination = true
      snapshot_id           = "snap-04d7ba812a8811e72"
      volume_size           = 16
      volume_type           = "standard"
    }
  }

  iam_instance_profile {
    arn = aws_iam_instance_profile.mediawiki.arn
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "mediawiki"
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      Name = "mediawiki"
    }
  }
}

resource "aws_iam_instance_profile" "mediawiki" {
  name = "MediaWiki"
  role = aws_iam_role.mediawiki.name
}

resource "aws_instance" "mediawiki" {
  ebs_optimized        = true
  ami                  = "ami-0a20c8152821c73ba"
  instance_type        = "t3.micro"
  key_name             = aws_key_pair.femiwiki.key_name
  monitoring           = false
  iam_instance_profile = aws_iam_instance_profile.mediawiki.name

  vpc_security_group_ids = [
    aws_default_security_group.default.id,
    aws_security_group.loadbalancer.id,
    aws_security_group.mediawiki.id,
  ]

  root_block_device {
    delete_on_termination = true
    encrypted             = false
    iops                  = 0
    volume_size           = 16
    volume_type           = "standard"
  }

  credit_specification {
    cpu_credits = "unlimited"
  }

  tags = {
    Name = "mediawiki"
  }

  volume_tags = {
    Name = "mediawiki"
  }

  # # 이 부분을 주석 해제하면 인스턴스가 Replacement 됩니다.
  # user_data = <<EOF
  # #!/bin/bash
  # set -euo pipefail; IFS=$'\n\t'

  # git clone https://github.com/femiwiki/mediawiki.git ~/mediawiki/
  # # TODO: Download seceret from S3
  # cp ~/mediawiki/configs/secret.php.example ~/mediawiki/configs/secret.php
  # sudo docker swarm init
  # sudo docker stack deploy --prune -c ~/mediawiki/production.yml mediawiki
  # EOF
}

resource "aws_instance" "database_bots" {
  ebs_optimized           = true
  ami                     = "ami-0019c8208fd95e551"
  instance_type           = "t3.nano"
  key_name                = aws_key_pair.femiwiki.key_name
  monitoring              = false
  iam_instance_profile    = aws_iam_instance_profile.upload_backup.name
  disable_api_termination = true
  vpc_security_group_ids = [
    aws_default_security_group.default.id,
    aws_security_group.db.id,
  ]

  root_block_device {
    delete_on_termination = false
    encrypted             = false
    iops                  = 100
    volume_size           = 16
    volume_type           = "gp2"
  }

  credit_specification {
    cpu_credits = "unlimited"
  }

  tags = {
    Name = "database+bots"
  }

  volume_tags = {
    Name = "database+bots"
  }

  # # 이 부분을 주석 해제하면 인스턴스가 Replacement 됩니다.
  # user_data = <<EOF
  # #!/bin/bash
  # set -euo pipefail; IFS=$'\n\t'

  # git clone https://github.com/femiwiki/database.git ~/swarm/
  # # TODO: Download SQL dump from S3
  # sudo docker swarm init
  # docker stack deploy --prune -c ~/swarm/database.yml database
  # docker stack deploy --prune -c ~/swarm/memcached.yml memcached
  # docker stack deploy --prune -c ~/swarm/bots.yml botse
  # EOF
}

resource "aws_iam_instance_profile" "upload_backup" {
  name = "UploadBackup"
  role = aws_iam_role.upload_backup.name
}
