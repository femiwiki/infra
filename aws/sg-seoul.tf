#
# Web
#
resource "aws_security_group" "web_seoul" {
  region      = local.seoul_region
  name        = "web"
  description = "Receives public HTTP and HTTPS"
  vpc_id      = aws_vpc.seoul.id

  tags = { Name = "web" }
}

resource "aws_vpc_security_group_ingress_rule" "web_seoul_http" {
  region            = local.seoul_region
  security_group_id = aws_security_group.web_seoul.id
  description       = "http"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "web_seoul_https" {
  region            = local.seoul_region
  security_group_id = aws_security_group.web_seoul.id
  description       = "https"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "web_seoul" {
  region            = local.seoul_region
  security_group_id = aws_security_group.web_seoul.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

#
# Database
#
resource "aws_security_group" "database_seoul" {
  region      = local.seoul_region
  name        = "database"
  description = "Receives database connections"
  vpc_id      = aws_vpc.seoul.id

  tags = { Name = "database" }
}

resource "aws_vpc_security_group_ingress_rule" "database_seoul_self" {
  region                       = local.seoul_region
  security_group_id            = aws_security_group.database_seoul.id
  description                  = "replication"
  ip_protocol                  = "tcp"
  from_port                    = 3306
  to_port                      = 3306
  referenced_security_group_id = aws_security_group.database_seoul.id
}

resource "aws_vpc_security_group_ingress_rule" "database_seoul_db_client" {
  region                       = local.seoul_region
  security_group_id            = aws_security_group.database_seoul.id
  description                  = "From a database-client"
  ip_protocol                  = "tcp"
  from_port                    = 3306
  to_port                      = 3306
  referenced_security_group_id = aws_security_group.database_client_seoul.id
}

resource "aws_vpc_security_group_egress_rule" "database_seoul" {
  region            = local.seoul_region
  security_group_id = aws_security_group.database_seoul.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

#
# Anything allowed to reach the database
#
resource "aws_security_group" "database_client_seoul" {
  region      = local.seoul_region
  name        = "database-client"
  description = "May reach the database"
  vpc_id      = aws_vpc.seoul.id

  tags = { Name = "database-client" }
}

#
# EC2 Instance Connect, for when SSM will not do
#
resource "aws_security_group" "instance_connect_seoul" {
  region      = local.seoul_region
  name        = "instance-connect"
  description = "EC2 Instance Connect"
  vpc_id      = aws_vpc.seoul.id

  tags = { Name = "instance-connect" }
}

resource "aws_vpc_security_group_ingress_rule" "instance_connect_seoul" {
  region            = local.seoul_region
  security_group_id = aws_security_group.instance_connect_seoul.id
  description       = "EC2 Instance Connect Browser-based client"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = "13.209.1.56/29"
}

resource "aws_vpc_security_group_ingress_rule" "database_seoul_from_tokyo" {
  region            = local.seoul_region
  security_group_id = aws_security_group.database_seoul.id
  description       = "From the Tokyo VPC, for the cutover and the stragglers after it"
  ip_protocol       = "tcp"
  from_port         = 3306
  to_port           = 3306
  cidr_ipv4         = aws_default_vpc.default.cidr_block
}
