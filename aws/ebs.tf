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
