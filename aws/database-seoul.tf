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
    primary_host    = ""
    region          = local.seoul_region
    backups_bucket  = module.backups_seoul.s3_bucket_id

    alloy_install = local.alloy_install["database"]
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
    Role        = "database"
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

# The address the app and replicas reach the primary at. The swap moves it to
# the promoted host; this attachment is only the first one.
resource "aws_network_interface" "database" {
  region          = local.seoul_region
  subnet_id       = aws_subnet.seoul.id
  private_ips     = [cidrhost(aws_subnet.seoul.cidr_block, 10)]
  security_groups = [aws_security_group.database_seoul.id]

  tags = { Name = "database primary" }
}

resource "aws_network_interface_attachment" "database" {
  region               = local.seoul_region
  instance_id          = aws_instance.database[local.database_primary].id
  network_interface_id = aws_network_interface.database.id
  device_index         = 1
}

# Every host this launches is a replica of whoever holds the interface above.
resource "aws_launch_template" "database" {
  region        = local.seoul_region
  name          = "database"
  image_id      = "resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-minimal-kernel-6.1-arm64"
  instance_type = "t4g.small"
  ebs_optimized = true

  user_data = base64gzip(templatefile("res/user-data-mariadb.sh.tftpl", {
    mysql_server_id = ""
    primary_host    = one(aws_network_interface.database.private_ips)
    region          = local.seoul_region
    backups_bucket  = module.backups_seoul.s3_bucket_id

    alloy_install = local.alloy_install["database"]
  }))

  iam_instance_profile {
    name = aws_iam_instance_profile.database.name
  }

  vpc_security_group_ids = [
    aws_security_group.database_seoul.id,
    aws_security_group.instance_connect_seoul.id,
  ]

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      delete_on_termination = true
      volume_size           = 32
      volume_type           = "gp3"
    }
  }

  block_device_mappings {
    device_name = "/dev/sdf"
    ebs {
      delete_on_termination = true
      encrypted             = true
      volume_size           = 32
      volume_type           = "gp3"
    }
  }

  credit_specification {
    cpu_credits = "unlimited"
  }

  metadata_options {
    instance_metadata_tags = "enabled"
    http_tokens            = "required"
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "database"
      Role        = "database"
      MysqlBackup = "false"
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags          = { Name = "database" }
  }
}

# Empty until the swap workflow raises it for a replacement.
resource "aws_autoscaling_group" "database" {
  region              = local.seoul_region
  name                = "database"
  min_size            = 0
  max_size            = 2
  desired_capacity    = 0
  vpc_zone_identifier = [aws_subnet.seoul.id]

  launch_template {
    id      = aws_launch_template.database.id
    version = aws_launch_template.database.latest_version
  }

  lifecycle {
    ignore_changes = [desired_capacity]
  }
}
