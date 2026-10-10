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
  database_hosts   = toset(["5"])
  database_primary = "5"
}

moved {
  from = aws_ebs_volume.persistent_data_mysql_5
  to   = aws_ebs_volume.database["5"]
}

moved {
  from = aws_volume_attachment.persistent_data_mysql_5
  to   = aws_volume_attachment.database["5"]
}

moved {
  from = aws_instance.database_5
  to   = aws_instance.database["5"]
}

resource "aws_ebs_volume" "database" {
  for_each = local.database_hosts

  region            = local.seoul_region
  availability_zone = local.seoul_az
  type              = "gp3"
  size              = 32

  tags = { Name = "MariaDB data directory for server_id = ${each.key}" }
}

resource "aws_volume_attachment" "database" {
  for_each = local.database_hosts

  region      = local.seoul_region
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.database[each.key].id
  instance_id = aws_instance.database[each.key].id
}

resource "aws_instance" "database" {
  for_each = local.database_hosts

  region                      = local.seoul_region
  ami                         = data.aws_ami.amazon_linux_2_arm64_seoul.image_id
  availability_zone           = local.seoul_az
  subnet_id                   = aws_subnet.seoul.id
  disable_api_termination     = true
  disable_api_stop            = true
  ebs_optimized               = true
  iam_instance_profile        = aws_iam_instance_profile.database.name
  instance_type               = "t4g.small"
  monitoring                  = false
  user_data_replace_on_change = false

  user_data_base64 = base64gzip(templatefile("res/user-data-mariadb.sh.tftpl", {
    mysql_server_id = each.key
    region          = local.seoul_region
    backups_bucket  = aws_s3_bucket.backups_seoul.bucket

    alloy_install = local.alloy_install["database-${each.key}"]
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

  tags = {
    Name        = "database-${each.key}"
    MysqlBackup = tostring(each.key == local.database_primary)
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      ami,
      user_data,
      user_data_base64,
    ]
  }
}
