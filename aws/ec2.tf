data "aws_availability_zone" "femiwiki" {
  name = "ap-northeast-1a"
}

resource "aws_instance" "database" {
  ami                         = data.aws_ami.amazon_linux_2_arm64.image_id
  availability_zone           = data.aws_availability_zone.femiwiki.name
  disable_api_termination     = true
  disable_api_stop            = true
  ebs_optimized               = true
  iam_instance_profile        = aws_iam_instance_profile.database.name
  instance_type               = "t4g.small"
  monitoring                  = false
  user_data_replace_on_change = false

  user_data = templatefile("res/user-data-mysql.sh.tftpl", {
    mysql_data_dir  = "/var/lib/mysql" # Default
    mysql_server_id = "2"

    alloy_config = templatefile("res/config.alloy.tftpl", {
      name                = "mysql"
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
    aws_security_group.mysql.id,
  ]

  root_block_device {
    delete_on_termination = true
    volume_size           = 32
    volume_type           = "gp3"
  }

  credit_specification {
    cpu_credits = "unlimited"
  }

  metadata_options {
    instance_metadata_tags = "enabled"
  }

  tags = {
    Name = "database"
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      ami,
      user_data,
    ]
  }
}

resource "aws_instance" "docker" {
  ami                         = data.aws_ami.amazon_linux_2_arm64.image_id
  availability_zone           = data.aws_availability_zone.femiwiki.name
  disable_api_termination     = true
  disable_api_stop            = true
  ebs_optimized               = true
  iam_instance_profile        = aws_iam_instance_profile.femiwiki.name
  instance_type               = "t4g.small"
  monitoring                  = false
  user_data_replace_on_change = false

  user_data = templatefile("res/user-data-docker-provider.tftpl", {
    alloy_config = templatefile("res/config.alloy.tftpl", {
      name                = "femiwiki"
      prometheus_endpoint = "https://prometheus-prod-49-prod-ap-northeast-0.grafana.net/api/prom/push"
      prometheus_username = "1835631"
      prometheus_password = var.prometheus_password
      loki_endpoint       = "https://logs-prod-030.grafana.net/loki/api/v1/push"
      loki_username       = "1017101"
      loki_password       = var.loki_password
    })
    ca_cert_pem     = tls_self_signed_cert.ca_cert.cert_pem
    server_cert_pem = tls_locally_signed_cert.server_cert.cert_pem
    server_key_pem  = tls_private_key.server_key.private_key_pem
  })

  vpc_security_group_ids = [
    aws_default_security_group.default.id,
    aws_security_group.femiwiki.id,
    aws_security_group.mediawiki.id,
  ]

  root_block_device {
    delete_on_termination = true
    volume_size           = 32
    volume_type           = "gp3"
  }

  credit_specification {
    cpu_credits = "unlimited"
  }

  metadata_options {
    instance_metadata_tags = "enabled"
  }

  tags = {
    Name = "docker"
  }

  lifecycle {
    ignore_changes = [
      ami,
      user_data,
    ]
  }
}
