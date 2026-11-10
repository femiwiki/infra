resource "aws_eip" "web" {
  domain = "vpc"

  tags = { Name = "femiwiki.com" }
}
