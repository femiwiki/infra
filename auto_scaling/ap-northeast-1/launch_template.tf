resource "aws_launch_template" "base" {
  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      delete_on_termination = true
      iops                  = "0"
      snapshot_id           = "snap-0de1ef9e4ea75d3a0"
      volume_size           = "8"
      volume_type           = "standard"
    }
  }

  credit_specification {
    cpu_credits = "unlimited"
  }

  description             = "Base Launch Configuration"
  disable_api_termination = false
  ebs_optimized           = true

  iam_instance_profile {
    arn = "arn:aws:iam::302617221463:instance-profile/AmazonS3Access"
  }

  image_id                             = "ami-0019c8208fd95e551"
  instance_initiated_shutdown_behavior = "terminate"
  instance_type                        = "t3.nano"
  key_name                             = "femiwiki-2018-09-15"
  name                                 = "base"

  placement {
    tenancy = "default"
  }

  tag_specifications {
    resource_type = "instance"

    tags {
      Name = "mediawiki"
    }
  }

  tag_specifications {
    resource_type = "volume"

    tags {
      Name = "mediawiki"
    }
  }

  tags                   {}
  vpc_security_group_ids = ["sg-03aebf67", "sg-07e51fb6f6719fc57"]
}

resource "aws_launch_template" "mediawiki" {
  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      delete_on_termination = true
      iops                  = "0"
      snapshot_id           = "snap-04d7ba812a8811e72"
      volume_size           = "8"
      volume_type           = "standard"
    }
  }

  credit_specification {
    cpu_credits = "unlimited"
  }

  description             = "Disable spot"
  disable_api_termination = false
  ebs_optimized           = true

  iam_instance_profile {
    arn = "arn:aws:iam::302617221463:instance-profile/AmazonS3Access"
  }

  image_id                             = "ami-0a20c8152821c73ba"
  instance_initiated_shutdown_behavior = "terminate"
  instance_type                        = "t3.nano"
  key_name                             = "femiwiki-2018-09-15"
  name                                 = "mediawiki"

  placement {
    tenancy = "default"
  }

  tag_specifications {
    resource_type = "instance"

    tags {
      Name = "mediawiki"
    }
  }

  tag_specifications {
    resource_type = "volume"

    tags {
      Name = "mediawiki"
    }
  }

  tags                   {}
  vpc_security_group_ids = ["sg-03aebf67", "sg-07e51fb6f6719fc57"]
}
