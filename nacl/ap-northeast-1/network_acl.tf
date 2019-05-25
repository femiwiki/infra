resource "aws_network_acl" "acl-ca994bae" {
  egress {
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = "0"
    icmp_code  = "0"
    icmp_type  = "0"
    protocol   = "-1"
    rule_no    = "100"
    to_port    = "0"
  }

  ingress {
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = "0"
    icmp_code  = "0"
    icmp_type  = "0"
    protocol   = "-1"
    rule_no    = "100"
    to_port    = "0"
  }

  subnet_ids = ["${data.terraform_remote_state.subnet.aws_subnet_subnet-9da70beb_id}", "${data.terraform_remote_state.subnet.aws_subnet_subnet-e5d929bd_id}", "${data.terraform_remote_state.subnet.aws_subnet_subnet-2581d80d_id}"]
  tags       {}
  vpc_id     = "${data.terraform_remote_state.vpc.aws_vpc_vpc-a4749ac0_id}"
}
