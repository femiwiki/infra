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
    volume_type = "gp3"
  }

  credit_specification {
    cpu_credits = "unlimited"
  }

  tags = {
    Name = "Main Server"
  }

  volume_tags = {
    Name = "Main Server"
  }

  user_data = file("res/bootstrap.sh")

  lifecycle {
    ignore_changes = [
      ami,
      user_data,
      # https://github.com/femiwiki/infra/issues/88
      volume_tags,
    ]
  }
}

resource "aws_eip" "femiwiki" {
  instance = aws_instance.femiwiki_green.id
  vpc      = true
}

resource "aws_ebs_volume" "persistent_data" {
  availability_zone = "ap-northeast-1a"
  size              = 8
  tags = {
    Name = "Mysql data-dir (legacy)"
  }
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
  instance_type           = "t4g.small"
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
    volume_type           = "gp3"
  }

  credit_specification {
    cpu_credits = "unlimited"
  }

  tags = {
    Name = "Experimental Arm 64 Server"
  }

  user_data = file("res/bootstrap.sh")

  lifecycle {
    ignore_changes = [
      ami,
      user_data,
      # https://github.com/femiwiki/infra/issues/88
      volume_tags,
    ]
  }
}

resource "aws_ebs_volume" "persistent_data_mysql" {
  availability_zone = data.aws_availability_zone.femiwiki_arm64.name
  type              = "gp3"
  size              = 8
  tags = {
    Name = "Mysql for Experimental Arm 64 Server"
  }
}

resource "aws_ebs_volume" "persistent_data_caddycerts" {
  availability_zone = data.aws_availability_zone.femiwiki_arm64.name
  type              = "gp3"
  size              = 1
  tags = {
    Name = "Caddycerts for Experimental Arm 64 Server"
  }
}
