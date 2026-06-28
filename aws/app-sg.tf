#
# Backend ASG security group (FrankenPHP serving nodes)
#
# The backend is reachable ONLY from the edge SG (aws_security_group.femiwiki):
# the edge Caddy reverse_proxy + its active /healthz-ready checks dial :8080.
# No world ingress, no 80/443 on the backend. DB access is granted by ALSO
# attaching the pre-existing aws_security_group.mediawiki to the launch template
# (the mysql_ingress_mediawiki rule in sg.tf already covers 3306 from that SG).
#
resource "aws_security_group" "app" {
  name        = "app"
  description = "Femiwiki backend ASG nodes (FrankenPHP, plain HTTP :8080)"
  vpc_id      = aws_default_vpc.default.id

  tags = {
    Name = "App"
  }
}

resource "aws_security_group_rule" "app_ingress_http_from_edge" {
  security_group_id        = aws_security_group.app.id
  description              = "FrankenPHP :8080 from the edge Caddy only"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 8080
  to_port                  = 8080
  source_security_group_id = aws_security_group.femiwiki.id
}

resource "aws_security_group_rule" "app_egress" {
  security_group_id = aws_security_group.app.id
  description       = "all egress (SSM, S3, SES, Grafana Cloud, image pull)"
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}

#
# Edge SG additions: the shared memcached lives on the edge (network_mode=host).
# memcached has no auth, so it must be reachable from the app SG ONLY, never world.
#
resource "aws_security_group_rule" "femiwiki_ingress_memcached_from_app" {
  security_group_id        = aws_security_group.femiwiki.id
  description              = "memcached from backend ASG nodes only"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 11211
  to_port                  = 11211
  source_security_group_id = aws_security_group.app.id
}
