locals {
  seoul_region = "ap-northeast-2"
  seoul_az     = "ap-northeast-2a"
}

resource "aws_vpc" "seoul" {
  region               = local.seoul_region
  cidr_block           = "10.20.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "femiwiki-seoul" }
}

resource "aws_subnet" "seoul" {
  region                  = local.seoul_region
  vpc_id                  = aws_vpc.seoul.id
  availability_zone       = local.seoul_az
  cidr_block              = "10.20.0.0/20"
  map_public_ip_on_launch = true

  tags = { Name = "femiwiki-seoul" }
}

resource "aws_internet_gateway" "seoul" {
  region = local.seoul_region
  vpc_id = aws_vpc.seoul.id

  tags = { Name = "femiwiki-seoul" }
}

resource "aws_route_table" "seoul" {
  region = local.seoul_region
  vpc_id = aws_vpc.seoul.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.seoul.id
  }

  tags = { Name = "femiwiki-seoul" }
}

resource "aws_route_table_association" "seoul" {
  region         = local.seoul_region
  subnet_id      = aws_subnet.seoul.id
  route_table_id = aws_route_table.seoul.id
}
