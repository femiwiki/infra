locals {
  mysql_volume_device_name = "/dev/nvme1n1"
}

resource "aws_ebs_volume" "persistent_data_mysql" {
  availability_zone = data.aws_availability_zone.femiwiki.name
  type              = "gp3"
  size              = 8
  tags = {
    Name = "Mysql data directory for Main Server"
  }
}

resource "aws_ebs_volume" "persistent_data_mysql_2" {
  availability_zone = data.aws_availability_zone.femiwiki.name
  type              = "gp3"
  size              = 8
  tags = {
    Name = "MySQL data directory for MySQL server_id = 2"
  }
}

resource "aws_volume_attachment" "persistent_data_mysql_2" {
  device_name = local.mysql_volume_device_name
  volume_id   = aws_ebs_volume.persistent_data_mysql_2.id
  instance_id = aws_instance.database.id
}

resource "aws_ebs_volume" "persistent_data_caddycerts" {
  availability_zone = data.aws_availability_zone.femiwiki.name
  type              = "gp3"
  size              = 1
  tags = {
    Name = "Caddycerts"
  }
}
