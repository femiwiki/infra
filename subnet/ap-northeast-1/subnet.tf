resource "aws_subnet" "subnet-2581d80d" {
  assign_ipv6_address_on_creation = false
  cidr_block                      = "172.31.32.0/20"
  map_public_ip_on_launch         = true
  tags                            {}
  vpc_id                          = "${data.terraform_remote_state.vpc.aws_vpc_vpc-a4749ac0_id}"
}

resource "aws_subnet" "subnet-9da70beb" {
  assign_ipv6_address_on_creation = false
  cidr_block                      = "172.31.16.0/20"
  map_public_ip_on_launch         = true
  tags                            {}
  vpc_id                          = "${data.terraform_remote_state.vpc.aws_vpc_vpc-a4749ac0_id}"
}

resource "aws_subnet" "subnet-e5d929bd" {
  assign_ipv6_address_on_creation = false
  cidr_block                      = "172.31.0.0/20"
  map_public_ip_on_launch         = true
  tags                            {}
  vpc_id                          = "${data.terraform_remote_state.vpc.aws_vpc_vpc-a4749ac0_id}"
}
