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

# Nomad ports
#   Reference: https://www.nomadproject.io/docs/install/production/requirements#ports-used
resource "aws_security_group_rule" "femiwiki_ingress_internal_nomad" {
  security_group_id = aws_security_group.nomad_cluster.id
  description       = "Nomad"

  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 4646
  to_port                  = 4648
  source_security_group_id = aws_security_group.nomad_cluster.id
}

resource "aws_security_group_rule" "femiwiki_ingress_internal_nomad_dynamic" {
  security_group_id = aws_security_group.nomad_cluster.id
  description       = "Nomad dynamic ports"

  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 20000
  to_port                  = 32000
  source_security_group_id = aws_security_group.nomad_cluster.id
}
