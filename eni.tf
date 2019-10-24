resource "aws_network_interface" "database_bots" {
  description = "Primary network interface"

  subnet_id   = aws_default_subnet.default["c"].id
  private_ips = ["172.31.11.11"]
  security_groups = [
    aws_default_security_group.default.id,
    aws_security_group.db.id,
  ]

  attachment {
    instance     = "${aws_instance.database_bots.id}"
    device_index = 0
  }

  tags = {
    Name = "database+bots"
  }
}
