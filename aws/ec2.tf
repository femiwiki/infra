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

resource "aws_eip" "femiwiki" {
  instance = aws_instance.femiwiki.id
  vpc      = true
}

resource "aws_eip" "test_femiwiki" {
  # instance = aws_instance.femiwiki_consul_test.id
  vpc = true
}

data "aws_availability_zone" "femiwiki" {
  name = "ap-northeast-1a"
}

#
# EBS volumes
#

resource "aws_ebs_volume" "persistent_data_mysql" {
  availability_zone = data.aws_availability_zone.femiwiki.name
  type              = "gp3"
  size              = 8
  tags = {
    Name = "Mysql data directory for Main Server"
  }
}

resource "aws_ebs_volume" "persistent_data_caddycerts" {
  availability_zone = data.aws_availability_zone.femiwiki.name
  type              = "gp3"
  size              = 1
  tags = {
    Name = "Caddycerts for Main Server"
  }
}

#
# Femiwiki main server
#

resource "aws_instance" "femiwiki" {
  ebs_optimized           = true
  ami                     = data.aws_ami.amazon_linux_2_arm64.image_id
  instance_type           = "t4g.small"
  key_name                = aws_key_pair.femiwiki.key_name
  monitoring              = false
  iam_instance_profile    = aws_iam_instance_profile.femiwiki.name
  disable_api_termination = true
  availability_zone       = data.aws_availability_zone.femiwiki.name

  vpc_security_group_ids = [
    aws_default_security_group.default.id,
    aws_security_group.femiwiki.id,
    aws_security_group.nomad_cluster.id,
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

# Exprimental instances for consul test
# https://github.com/femiwiki/femiwiki/issues/253

resource "aws_instance" "femiwiki_consul_test_server" {
  ebs_optimized           = true
  ami                     = data.aws_ami.amazon_linux_2_arm64.image_id
  instance_type           = "t4g.micro"
  key_name                = aws_key_pair.femiwiki.key_name
  monitoring              = false
  iam_instance_profile    = aws_iam_instance_profile.femiwiki.name
  disable_api_termination = false # during test period
  availability_zone       = data.aws_availability_zone.femiwiki.name

  vpc_security_group_ids = [
    aws_default_security_group.default.id,
    aws_security_group.femiwiki.id,
    aws_security_group.nomad_cluster.id,
  ]

  root_block_device {
    delete_on_termination = true
    volume_size           = 8
    volume_type           = "gp3"
  }

  credit_specification {
    cpu_credits = "unlimited"
  }

  tags = {
    Name  = "Experimetal micro instance for nomad clustrering (Server)"
    Nomad = "femiwiki"
  }

  user_data = file("res/bootstrap-consul.sh")

  lifecycle {
    ignore_changes = [
      ami,
      user_data,
      # https://github.com/femiwiki/infra/issues/88
      volume_tags,
    ]
  }
}

resource "aws_instance" "femiwiki_consul_test_client" {
  count                   = 2
  ebs_optimized           = true
  ami                     = data.aws_ami.amazon_linux_2_arm64.image_id
  instance_type           = "t4g.micro"
  key_name                = aws_key_pair.femiwiki.key_name
  monitoring              = false
  iam_instance_profile    = aws_iam_instance_profile.femiwiki.name
  disable_api_termination = false # during test period
  availability_zone       = data.aws_availability_zone.femiwiki.name

  vpc_security_group_ids = [
    aws_default_security_group.default.id,
    aws_security_group.femiwiki.id,
    aws_security_group.nomad_cluster.id,
  ]

  root_block_device {
    delete_on_termination = true
    volume_size           = 8
    volume_type           = "gp3"
  }

  credit_specification {
    cpu_credits = "unlimited"
  }

  tags = {
    Name  = "experimetal micro instance for nomad clustrering (Client)"
    Nomad = "femiwiki"
  }

  user_data = file("res/bootstrap-consul.sh")

  lifecycle {
    ignore_changes = [
      ami,
      user_data,
      # https://github.com/femiwiki/infra/issues/88
      volume_tags,
    ]
  }
}
