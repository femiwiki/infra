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
  domain   = "vpc"
}

resource "aws_eip" "test_femiwiki" {
  instance = aws_instance.test_femiwiki[0].id
  domain   = "vpc"
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
# Femiwiki Main Server
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
    volume_size           = 20
    volume_type           = "gp3"
  }

  credit_specification {
    cpu_credits = "unlimited"
  }

  tags = {
    Name = "Main Server"
  }

  user_data = templatefile("res/user-data.sh.tftpl", {
    enable_dns_forwarding = false
    nomad_config = templatefile("res/nomad.hcl", {
      enable_consul = false
    })
    consul_config = file("res/consul.hcl")

    start_nomad  = true
    start_consul = false
    bootstrap    = true
  })
  user_data_replace_on_change = false

  lifecycle {
    ignore_changes = [
      ami,
      user_data,
    ]
  }
}


#
# Femiwiki Test Server
#

resource "aws_instance" "test_femiwiki" {
  count                       = 2
  ami                         = data.aws_ami.amazon_linux_2_arm64.image_id
  availability_zone           = data.aws_availability_zone.femiwiki.name
  disable_api_termination     = true
  ebs_optimized               = true
  iam_instance_profile        = aws_iam_instance_profile.femiwiki.name
  instance_type               = "t4g.small"
  key_name                    = aws_key_pair.femiwiki.key_name
  monitoring                  = false
  user_data_replace_on_change = true

  user_data = templatefile("res/user-data.sh.tftpl", {
    enable_dns_forwarding = true
    nomad_config = templatefile("res/nomad.hcl", {
      enable_consul = true
    })
    consul_config = file("res/consul.hcl")

    start_nomad  = true
    start_consul = true
    bootstrap    = count.index == 0
  })

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

  metadata_options {
    instance_metadata_tags = "enabled"
  }

  tags = {
    Name           = count.index == 0 ? "Test Server" : "Test Server ${count.index + 1}"
    ConsulAutoJoin = "auto-join"
  }

  lifecycle {
    ignore_changes = [
      ami,
      user_data,
    ]
  }
}
