resource "aws_internet_gateway" "igw-72c9b517" {
  tags   {}
  vpc_id = "${data.terraform_remote_state.vpc.aws_vpc_vpc-a4749ac0_id}"
}
