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
  instance = aws_instance.femiwiki_blue.id
  domain   = "vpc"
  tags     = { Name = "femiwiki.com" }
}

resource "aws_eip" "test_femiwiki" {
  instance = aws_eip.femiwiki.instance == aws_instance.femiwiki_blue.id ? null : aws_instance.femiwiki_blue.id
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

#
# Femiwiki Blue Cluster
#
resource "aws_instance" "femiwiki_blue" {
  ami                         = data.aws_ami.amazon_linux_2_arm64.image_id
  availability_zone           = data.aws_availability_zone.femiwiki.name
  disable_api_termination     = true
  ebs_optimized               = true
  iam_instance_profile        = aws_iam_instance_profile.femiwiki.name
  instance_type               = "t4g.medium"
  key_name                    = aws_key_pair.femiwiki.key_name
  monitoring                  = false
  user_data_replace_on_change = false

  user_data = templatefile("res/user-data-orchestratorless.tftpl", {
    alloy_config = templatefile("res/config.alloy.tftpl", {
      name                = "femiwiki-orchestratorless"
      prometheus_endpoint = "https://prometheus-prod-49-prod-ap-northeast-0.grafana.net/api/prom/push"
      prometheus_username = "1835631"
      prometheus_password = var.prometheus_password
      loki_endpoint       = "https://logs-prod-030.grafana.net/loki/api/v1/push"
      loki_username       = "1017101"
      loki_password       = var.loki_password
    })
  })

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

  # TODO Mount MySQL dir EBS

  credit_specification {
    cpu_credits = "unlimited"
  }

  metadata_options {
    instance_metadata_tags = "enabled"
  }

  tags = {
    Name = "Femiwiki Server orchestratorless"
  }

  lifecycle {
    ignore_changes = [
      ami,
      user_data,
    ]
  }
}

#
# Femiwiki Green Cluster
#
resource "aws_instance" "femiwiki_green" {
  count                       = 1
  ami                         = data.aws_ami.amazon_linux_2_arm64.image_id
  availability_zone           = data.aws_availability_zone.femiwiki.name
  disable_api_termination     = false
  ebs_optimized               = true
  iam_instance_profile        = aws_iam_instance_profile.femiwiki.name
  instance_type               = "t4g.nano"
  key_name                    = aws_key_pair.femiwiki.key_name
  monitoring                  = false
  user_data_replace_on_change = true

  user_data = templatefile("res/user-data.sh.tftpl", {
    enable_dns_forwarding = true
    nomad_config = templatefile("res/nomad.hcl.tftpl", {
      name            = "femiwiki-${count.index + 1}${count.index == 0 ? "-main" : ""}"
      enable_consul   = true
      main_elastic_ip = count.index == 0
    })
    consul_config = file("res/consul.hcl")
    alloy_config = templatefile("res/config.alloy.tftpl", {
      name                = "femiwiki-${count.index + 1}${count.index == 0 ? "-main" : ""}"
      prometheus_endpoint = "https://prometheus-prod-49-prod-ap-northeast-0.grafana.net/api/prom/push"
      prometheus_username = "1835631"
      prometheus_password = var.prometheus_password
      loki_endpoint       = "https://logs-prod-030.grafana.net/loki/api/v1/push"
      loki_username       = "1017101"
      loki_password       = var.loki_password
    })

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
    volume_size           = 16
    volume_type           = "gp3"
  }

  credit_specification {
    cpu_credits = "unlimited"
  }

  metadata_options {
    instance_metadata_tags = "enabled"
  }

  tags = {
    Name           = "Femiwiki Server ${count.index + 1}"
    ConsulAutoJoin = "auto-join"
  }

  lifecycle {
    ignore_changes = [
      ami,
      user_data,
    ]
  }
}

