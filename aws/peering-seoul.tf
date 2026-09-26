resource "aws_vpc_peering_connection" "tokyo_seoul" {
  vpc_id      = aws_default_vpc.default.id
  peer_vpc_id = aws_vpc.seoul.id
  peer_region = local.seoul_region
  auto_accept = false

  tags = { Name = "tokyo-seoul" }
}

resource "aws_vpc_peering_connection_accepter" "seoul" {
  region                    = local.seoul_region
  vpc_peering_connection_id = aws_vpc_peering_connection.tokyo_seoul.id
  auto_accept               = true

  tags = { Name = "tokyo-seoul" }
}

resource "aws_route" "tokyo_to_seoul" {
  route_table_id            = aws_default_vpc.default.main_route_table_id
  destination_cidr_block    = aws_vpc.seoul.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.tokyo_seoul.id

  depends_on = [aws_vpc_peering_connection_accepter.seoul]
}

resource "aws_security_group_rule" "mysql_ingress_seoul" {
  security_group_id = aws_security_group.mysql.id
  description       = "replication from Seoul"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 3306
  to_port           = 3306
  cidr_blocks       = [aws_vpc.seoul.cidr_block]
}
