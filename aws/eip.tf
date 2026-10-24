resource "aws_eip" "seoul" {
  region = local.seoul_region
  domain = "vpc"

  tags = { Name = "femiwiki.com" }
}
