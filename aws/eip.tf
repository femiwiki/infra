resource "aws_eip" "femiwiki" {
  domain = "vpc"
  tags   = { Name = "femiwiki.com" }
}

resource "aws_eip_association" "femiwiki" {
  allocation_id = aws_eip.femiwiki.id
  instance_id   = aws_instance.docker.id
}


