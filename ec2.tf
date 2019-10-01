resource "aws_key_pair" "femiwiki" {
  key_name   = "femiwiki-2018-09-15"
  public_key = file("res/femiwiki_rsa.pub")
}

# TODO: base launch template은 별 쓸모가 없다. DB용 launch template로 바꾸자.
resource "aws_launch_template" "base" {
  name        = "base"
  description = "Base Launch Template"

  disable_api_termination              = true
  ebs_optimized                        = true
  image_id                             = "ami-0019c8208fd95e551"
  instance_initiated_shutdown_behavior = "stop"
  instance_type                        = "t3.nano"
  key_name                             = aws_key_pair.femiwiki.key_name
  vpc_security_group_ids               = ["sg-03aebf67", "sg-07e51fb6f6719fc57"]

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      delete_on_termination = false
      snapshot_id           = "snap-0de1ef9e4ea75d3a0"
      volume_size           = 16
      volume_type           = "gp2"
    }
  }

  iam_instance_profile {
    arn = "arn:aws:iam::302617221463:instance-profile/AmazonS3Access"
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "database+bots"
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      Name = "database+bots"
    }
  }
}

resource "aws_launch_template" "mediawiki" {
  name        = "mediawiki"
  description = "A launch template for mediawiki servers"

  disable_api_termination              = true
  ebs_optimized                        = true
  image_id                             = "ami-0a20c8152821c73ba"
  instance_initiated_shutdown_behavior = "terminate"
  instance_type                        = "t3.micro"
  key_name                             = aws_key_pair.femiwiki.key_name
  vpc_security_group_ids               = ["sg-03aebf67", "sg-07e51fb6f6719fc57"]

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      delete_on_termination = true
      snapshot_id           = "snap-04d7ba812a8811e72"
      volume_size           = 16
      volume_type           = "standard"
    }
  }

  iam_instance_profile {
    arn = "arn:aws:iam::302617221463:instance-profile/AmazonS3Access"
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "mediawiki"
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      Name = "mediawiki"
    }
  }
}
