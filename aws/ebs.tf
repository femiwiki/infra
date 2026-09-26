resource "aws_ebs_volume" "persistent_data_mysql_3" {
  availability_zone = data.aws_availability_zone.femiwiki.name
  type              = "gp3"
  size              = 32
  tags = {
    Name = "MySQL data directory for MySQL server_id = 3"
  }
}

resource "aws_volume_attachment" "persistent_data_mysql_3" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.persistent_data_mysql_3.id
  instance_id = aws_instance.database_3.id
}
