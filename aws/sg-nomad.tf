resource "aws_security_group" "nomad_cluster" {
  name        = "nomad-cluster"
  description = "nomad cluster"
  vpc_id      = aws_default_vpc.default.id

  tags = {
    Name = "Nomad Cluster"
  }
}

resource "aws_security_group_rule" "femiwiki_ingress_nomad" {
  security_group_id = aws_security_group.nomad_cluster.id
  description       = "nomad"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 4646
  to_port           = 4646
  # Allow everyone. Issue: https://github.com/femiwiki/nomad/issues/5
  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]
}

resource "aws_security_group_rule" "femiwiki_ingress_internal_nomad" {
  security_group_id = aws_security_group.nomad_cluster.id
  description       = "Nomad"

  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 4646
  to_port                  = 4648
  source_security_group_id = aws_security_group.nomad_cluster.id
}

#
# Consul ports
#   Refernce: https://www.consul.io/docs/install/ports
#

resource "aws_security_group_rule" "femiwiki_ingress_internal_consul_dns_tcp" {
  security_group_id = aws_security_group.nomad_cluster.id
  description       = "The Consul DNS server (TCP)"

  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 8600
  to_port                  = 8600
  source_security_group_id = aws_security_group.nomad_cluster.id
}

resource "aws_security_group_rule" "femiwiki_ingress_internal_consul_dns_udp" {
  security_group_id = aws_security_group.nomad_cluster.id
  description       = "The Consul DNS server (TCP)"

  type                     = "ingress"
  protocol                 = "udp"
  from_port                = 8600
  to_port                  = 8600
  source_security_group_id = aws_security_group.nomad_cluster.id
}

resource "aws_security_group_rule" "femiwiki_ingress_internal_consul_api" {
  security_group_id = aws_security_group.nomad_cluster.id
  description       = "The Consul HTTP API"

  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 8500
  to_port                  = 8500
  source_security_group_id = aws_security_group.nomad_cluster.id
}

resource "aws_security_group_rule" "femiwiki_ingress_internal_consul_grpc" {
  security_group_id = aws_security_group.nomad_cluster.id
  description       = "The Consul gRPC API"

  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 8502
  to_port                  = 8502
  source_security_group_id = aws_security_group.nomad_cluster.id
}

resource "aws_security_group_rule" "femiwiki_ingress_internal_consul_serf_tcp" {
  security_group_id = aws_security_group.nomad_cluster.id
  description       = "The Serf LAN ports (TCP)"

  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 8301
  to_port                  = 8302
  source_security_group_id = aws_security_group.nomad_cluster.id
}

resource "aws_security_group_rule" "femiwiki_ingress_internal_consul_serf_udp" {
  security_group_id = aws_security_group.nomad_cluster.id
  description       = "The Serf LAN ports (UDP)"

  type                     = "ingress"
  protocol                 = "udp"
  from_port                = 8301
  to_port                  = 8302
  source_security_group_id = aws_security_group.nomad_cluster.id
}

resource "aws_security_group_rule" "femiwiki_ingress_internal_consul_rpc" {
  security_group_id = aws_security_group.nomad_cluster.id
  description       = "Consul Server RPC address"

  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 8300
  to_port                  = 8300
  source_security_group_id = aws_security_group.nomad_cluster.id
}
