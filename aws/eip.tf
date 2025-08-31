resource "aws_eip" "femiwiki" {
  domain = "vpc"
  tags   = { Name = "femiwiki.com" }
}

resource "aws_eip_association" "femiwiki" {
  allocation_id = aws_eip.femiwiki.id
  instance_id   = aws_instance.femiwiki_blue.id
}

resource "aws_eip" "test_femiwiki" {
  domain = "vpc"
  tags   = { Name = "test.femiwiki.com" }
}

resource "aws_eip_association" "test_femiwiki" {
  count         = 0
  allocation_id = aws_eip.test_femiwiki.id
  instance_id   = aws_instance.femiwiki_blue.id
}


