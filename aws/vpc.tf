locals {
  availability_zones = {
    a = "ap-northeast-1a",
    c = "ap-northeast-1c",
    d = "ap-northeast-1d",
  }
}

resource "aws_default_vpc" "default" {}

resource "aws_default_subnet" "default" {
  for_each = local.availability_zones

  availability_zone = each.value
}
