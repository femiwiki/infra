# Renames that dropped the region suffix; Seoul is the only region the web stack uses.

moved {
  from = aws_instance.docker_seoul
  to   = aws_instance.docker
}

moved {
  from = aws_eip.seoul
  to   = aws_eip.web
}

moved {
  from = aws_eip_association.seoul
  to   = aws_eip_association.web
}

moved {
  from = aws_vpc.seoul
  to   = aws_vpc.main
}

moved {
  from = aws_subnet.seoul
  to   = aws_subnet.main
}

moved {
  from = aws_internet_gateway.seoul
  to   = aws_internet_gateway.main
}

moved {
  from = aws_route_table.seoul
  to   = aws_route_table.main
}

moved {
  from = aws_route_table_association.seoul
  to   = aws_route_table_association.main
}

moved {
  from = aws_security_group.web_seoul
  to   = aws_security_group.web
}

moved {
  from = aws_vpc_security_group_ingress_rule.web_seoul_http
  to   = aws_vpc_security_group_ingress_rule.web_http
}

moved {
  from = aws_vpc_security_group_ingress_rule.web_seoul_https
  to   = aws_vpc_security_group_ingress_rule.web_https
}

moved {
  from = aws_vpc_security_group_egress_rule.web_seoul
  to   = aws_vpc_security_group_egress_rule.web
}

moved {
  from = aws_security_group.database_seoul
  to   = aws_security_group.database
}

moved {
  from = aws_vpc_security_group_ingress_rule.database_seoul_self
  to   = aws_vpc_security_group_ingress_rule.database_self
}

moved {
  from = aws_vpc_security_group_ingress_rule.database_seoul_db_client
  to   = aws_vpc_security_group_ingress_rule.database_db_client
}

moved {
  from = aws_vpc_security_group_egress_rule.database_seoul
  to   = aws_vpc_security_group_egress_rule.database
}

moved {
  from = aws_security_group.database_client_seoul
  to   = aws_security_group.database_client
}

moved {
  from = aws_security_group.instance_connect_seoul
  to   = aws_security_group.instance_connect
}

moved {
  from = aws_vpc_security_group_ingress_rule.instance_connect_seoul
  to   = aws_vpc_security_group_ingress_rule.instance_connect
}

moved {
  from = aws_ssm_parameter.alloy_seoul
  to   = aws_ssm_parameter.alloy
}

moved {
  from = module.uploads_seoul
  to   = module.uploads
}
