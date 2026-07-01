#
# Default SG
#
resource "aws_default_security_group" "default" {
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
  security_group_id = aws_default_security_group.default.id
  description       = "EC2 Instance Connect Browser-based client"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_blocks       = ["3.112.23.0/29"]
}

#
# SG for the Femiwiki server
#
resource "aws_security_group" "femiwiki" {
  name        = "internal-server"
  description = "internal server"
  vpc_id      = aws_default_vpc.default.id

  tags = {
    Name = "Femiwiki"
  }
}

resource "aws_security_group_rule" "femiwiki_ingress_http" {
  security_group_id = aws_security_group.femiwiki.id
  description       = "http"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}

resource "aws_security_group_rule" "femiwiki_ingress_https" {
  security_group_id = aws_security_group.femiwiki.id
  description       = "https"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}

# Docker daemon TLS (2376) is dialed by the `docker` workspace from HCP Terraform runners
# (docker/backend.tf: host = tcp://<EIP>:2376). It was world-open; scope it to HCP
# Terraform's published API egress ranges so only TFC runs can reach the daemon (mTLS
# client-auth still required on top). A STATIC list is used deliberately: a data.http on
# app.terraform.io/api/meta/ip-ranges would add a plan-time dependency that can silently
# lock out the docker workspace if the endpoint is unreachable or the ranges rotate.
#
# Source of truth: https://app.terraform.io/api/meta/ip-ranges  (the "api" field).
# REVIEW periodically; if a TFC apply on the docker workspace starts failing to dial 2376,
# refresh this list first.
locals {
  tfc_api_cidrs = [
    "75.2.98.97/32",
    "99.83.150.238/32",
  ]
}

resource "aws_security_group_rule" "femiwiki_ingress_docker_tls" {
  security_group_id = aws_security_group.femiwiki.id
  description       = "Docker TLS 2376 - HCP Terraform runners only (was world-open)"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 2376
  to_port           = 2376
  cidr_blocks       = local.tfc_api_cidrs
}

resource "aws_security_group_rule" "femiwiki_egress" {
  security_group_id = aws_security_group.femiwiki.id

  type             = "egress"
  protocol         = "-1"
  from_port        = 0
  to_port          = 0
  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]
}

#
# MySQL
#
resource "aws_security_group" "mysql" {
  name        = "mysql"
  description = "MySQL"
  vpc_id      = aws_default_vpc.default.id

  tags = {
    Name = "MySQL"
  }
}

resource "aws_security_group_rule" "mysql_ingress_self" {
  security_group_id = aws_security_group.mysql.id
  description       = "replication"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 3306
  to_port           = 3306
  self              = true
}

resource "aws_security_group_rule" "mysql_ingress_mediawiki" {
  security_group_id        = aws_security_group.mysql.id
  description              = "MySQL from Mediawiki"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 3306
  to_port                  = 3306
  source_security_group_id = aws_security_group.mediawiki.id
}

resource "aws_security_group_rule" "mysql_egress" {
  security_group_id = aws_security_group.mysql.id

  type             = "egress"
  protocol         = "-1"
  from_port        = 0
  to_port          = 0
  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]
}

#
# MediaWiki
#
resource "aws_security_group" "mediawiki" {
  name        = "mediawiki"
  description = "MediaWiki"
  vpc_id      = aws_default_vpc.default.id

  tags = {
    Name = "MediaWiki"
  }
}
