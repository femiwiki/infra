resource "aws_eip" "femiwiki" {
  region = local.tokyo_region
  domain = "vpc"
  tags   = { Name = "femiwiki.com" }
}

resource "aws_eip_association" "femiwiki" {
  region        = local.tokyo_region
  allocation_id = aws_eip.femiwiki.id
  instance_id   = aws_instance.docker.id
}


