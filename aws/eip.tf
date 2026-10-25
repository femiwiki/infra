resource "aws_eip" "web" {
  region = local.seoul_region
  domain = "vpc"

  tags = { Name = "femiwiki.com" }
}
