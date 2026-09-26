data "aws_ami" "amazon_linux_2_arm64_seoul" {
  region      = local.seoul_region
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-minimal-*-kernel-6.1-arm64"]
  }

  filter {
    name   = "ena-support"
    values = ["true"]
  }
}

locals {
  alloy_install_database_seoul = replace(
    replace(file("res/install-alloy-config.sh"), "__REGION__", local.seoul_region),
    "__CONFIG__",
    templatefile("res/config.alloy.tftpl", merge(local.alloy_grafana, { name = "mysql-seoul", type = "database" }))
  )
}

resource "aws_ebs_volume" "persistent_data_mysql_4" {
  region            = local.seoul_region
  availability_zone = local.seoul_az
  type              = "gp3"
  size              = 32

  tags = { Name = "MySQL data directory for MySQL server_id = 4" }
}

resource "aws_volume_attachment" "persistent_data_mysql_4" {
  region      = local.seoul_region
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.persistent_data_mysql_4.id
  instance_id = aws_instance.database_4.id
}

resource "aws_instance" "database_4" {
  region                      = local.seoul_region
  ami                         = data.aws_ami.amazon_linux_2_arm64_seoul.image_id
  availability_zone           = local.seoul_az
  subnet_id                   = aws_subnet.seoul.id
  disable_api_termination     = false
  disable_api_stop            = false
  ebs_optimized               = true
  iam_instance_profile        = aws_iam_instance_profile.database.name
  instance_type               = "t4g.small"
  monitoring                  = false
  user_data_replace_on_change = false

  user_data_base64 = base64gzip(templatefile("res/user-data-mysql.sh.tftpl", {
    mysql_data_dir  = "/var/lib/mysql" # Default
    mysql_server_id = "4"
    region          = local.seoul_region
    backups_bucket  = aws_s3_bucket.backups.bucket

    alloy_install = local.alloy_install_database_seoul
    backup_script = local.mysql_backup_script["database-4"]
  }))

  vpc_security_group_ids = [
    aws_security_group.database_seoul.id,
    aws_security_group.instance_connect_seoul.id,
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
    http_tokens            = "required"
  }

  tags = { Name = "database-4" }

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      ami,
      user_data,
      user_data_base64,
    ]
  }
}
