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
  tags     = { Name = "femiwiki.com" }
}

resource "aws_eip" "test_femiwiki" {
  instance = aws_eip.femiwiki.instance == aws_instance.femiwiki.id ? null : aws_instance.femiwiki.id
  domain   = "vpc"
  tags     = { Name = "test.femiwiki.com" }
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
    Name = "Caddycerts"
  }
}

resource "aws_instance" "femiwiki" {
  ami                         = data.aws_ami.amazon_linux_2_arm64.image_id
  availability_zone           = data.aws_availability_zone.femiwiki.name
  disable_api_termination     = true
  ebs_optimized               = true
  iam_instance_profile        = aws_iam_instance_profile.femiwiki.name
  instance_type               = "t4g.medium"
  key_name                    = aws_key_pair.femiwiki.key_name
  monitoring                  = false
  user_data_replace_on_change = false

  user_data = templatefile("res/user-data.tftpl", {
    mount_mysql = "true"
    alloy_config = templatefile("res/config.alloy.tftpl", {
      name                = "femiwiki"
      prometheus_endpoint = "https://prometheus-prod-49-prod-ap-northeast-0.grafana.net/api/prom/push"
      prometheus_username = "1835631"
      prometheus_password = var.prometheus_password
      loki_endpoint       = "https://logs-prod-030.grafana.net/loki/api/v1/push"
      loki_username       = "1017101"
      loki_password       = var.loki_password
    })
    docker_compose_yml = file("res/docker-compose.yml")
  })

  vpc_security_group_ids = [
    aws_default_security_group.default.id,
    aws_security_group.femiwiki.id,
  ]

  root_block_device {
    delete_on_termination = true
    volume_size           = 16
    volume_type           = "gp3"
  }

  # TODO Mount MySQL dir EBS

  credit_specification {
    cpu_credits = "unlimited"
  }

  metadata_options {
    instance_metadata_tags = "enabled"
  }

  tags = {
    Name = "femiwiki.com"
  }

  lifecycle {
    ignore_changes = [
      ami,
      user_data,
    ]
  }
}

resource "aws_instance" "test_femiwiki" {
  ami                         = data.aws_ami.amazon_linux_2_arm64.image_id
  availability_zone           = data.aws_availability_zone.femiwiki.name
  disable_api_termination     = false
  ebs_optimized               = true
  iam_instance_profile        = aws_iam_instance_profile.femiwiki.name
  instance_type               = "t4g.small"
  key_name                    = aws_key_pair.femiwiki.key_name
  monitoring                  = false
  user_data_replace_on_change = false

  user_data = templatefile("res/user-data.tftpl", {
    mount_mysql = ""
    alloy_config = templatefile("res/config.alloy.tftpl", {
      name                = "test.femiwiki"
      prometheus_endpoint = "https://prometheus-prod-49-prod-ap-northeast-0.grafana.net/api/prom/push"
      prometheus_username = "1835631"
      prometheus_password = var.prometheus_password
      loki_endpoint       = "https://logs-prod-030.grafana.net/loki/api/v1/push"
      loki_username       = "1017101"
      loki_password       = var.loki_password
    })
    docker_compose_yml = file("res/docker-compose.yml")
  })

  vpc_security_group_ids = [
    aws_default_security_group.default.id,
    aws_security_group.femiwiki.id,
  ]

  root_block_device {
    delete_on_termination = true
    volume_size           = 16
    volume_type           = "gp3"
  }

  # TODO Mount MySQL dir EBS

  credit_specification {
    cpu_credits = "unlimited"
  }

  metadata_options {
    instance_metadata_tags = "enabled"
  }

  tags = {
    Name = "test.femiwiki.com"
  }

  lifecycle {
    ignore_changes = [
      ami,
      user_data,
    ]
  }
}
