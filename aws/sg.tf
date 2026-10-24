# Default SG
resource "aws_default_security_group" "default" {
  region = local.tokyo_region
  vpc_id = aws_default_vpc.default.id

  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  # NOTE: Do not manage the default SG's ingress rules with Terraform; manage them manually.
  # The reason is a secret.
  lifecycle {
    ignore_changes = [ingress]
  }
}

# See https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-connect-set-up.html#ec2-instance-connect-setup-security-group
resource "aws_security_group_rule" "default_instance_connect_browser_based_client" {
  region            = local.tokyo_region
  security_group_id = aws_default_security_group.default.id
  description       = "EC2 Instance Connect Browser-based client"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_blocks       = ["3.112.23.0/29"]
}

# Web
resource "aws_security_group" "web" {
  region      = local.seoul_region
  name        = "web"
  description = "Receives public HTTP and HTTPS"
  vpc_id      = aws_vpc.main.id

  tags = { Name = "web" }
}

# CloudFront reaches the origin over HTTPS only, so port 80 serves only
# readers who come straight to the box.
resource "aws_vpc_security_group_ingress_rule" "web_http" {
  for_each          = local.through_cloudfront ? toset([]) : toset(["http"])
  region            = local.seoul_region
  security_group_id = aws_security_group.web.id
  description       = "http"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "web_https" {
  region            = local.seoul_region
  security_group_id = aws_security_group.web.id
  description       = "https"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = local.through_cloudfront ? null : "0.0.0.0/0"
  prefix_list_id    = local.through_cloudfront ? data.aws_ec2_managed_prefix_list.cloudfront_origin_facing.id : null
}

# Counts as 55 of the group's 60 inbound rules, so it fits once, not twice
data "aws_ec2_managed_prefix_list" "cloudfront_origin_facing" {
  region = local.seoul_region
  name   = "com.amazonaws.global.cloudfront.origin-facing"
}

moved {
  from = aws_vpc_security_group_ingress_rule.web_http
  to   = aws_vpc_security_group_ingress_rule.web_http["http"]
}

resource "aws_vpc_security_group_egress_rule" "web" {
  region            = local.seoul_region
  security_group_id = aws_security_group.web.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# Database
resource "aws_security_group" "database" {
  region      = local.seoul_region
  name        = "database"
  description = "Receives database connections"
  vpc_id      = aws_vpc.main.id

  tags = { Name = "database" }
}

resource "aws_vpc_security_group_ingress_rule" "database_self" {
  region                       = local.seoul_region
  security_group_id            = aws_security_group.database.id
  description                  = "replication"
  ip_protocol                  = "tcp"
  from_port                    = 3306
  to_port                      = 3306
  referenced_security_group_id = aws_security_group.database.id
}

resource "aws_vpc_security_group_ingress_rule" "database_db_client" {
  region                       = local.seoul_region
  security_group_id            = aws_security_group.database.id
  description                  = "From a database-client"
  ip_protocol                  = "tcp"
  from_port                    = 3306
  to_port                      = 3306
  referenced_security_group_id = aws_security_group.database_client.id
}

resource "aws_vpc_security_group_egress_rule" "database" {
  region            = local.seoul_region
  security_group_id = aws_security_group.database.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# Anything allowed to reach the database
resource "aws_security_group" "database_client" {
  region      = local.seoul_region
  name        = "database-client"
  description = "May reach the database"
  vpc_id      = aws_vpc.main.id

  tags = { Name = "database-client" }
}

# EC2 Instance Connect, for when SSM will not do
resource "aws_security_group" "instance_connect" {
  region      = local.seoul_region
  name        = "instance-connect"
  description = "EC2 Instance Connect"
  vpc_id      = aws_vpc.main.id

  tags = { Name = "instance-connect" }
}

resource "aws_vpc_security_group_ingress_rule" "instance_connect" {
  region            = local.seoul_region
  security_group_id = aws_security_group.instance_connect.id
  description       = "EC2 Instance Connect Browser-based client"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = "13.209.1.56/29"
}

# Empty, so anything launched without a group gets no network access (#1277)
import {
  to = aws_default_security_group.vpc
  id = "sg-054ba860b1515c724"
}

resource "aws_default_security_group" "vpc" {
  region  = local.seoul_region
  vpc_id  = aws_vpc.main.id
  ingress = []
  egress  = []
}

# The region's default VPC, which nothing uses
data "aws_vpc" "default" {
  region  = local.seoul_region
  default = true
}

import {
  to = aws_default_security_group.default_vpc
  id = "sg-40f2a829"
}

resource "aws_default_security_group" "default_vpc" {
  region  = local.seoul_region
  vpc_id  = data.aws_vpc.default.id
  ingress = []
  egress  = []
}
