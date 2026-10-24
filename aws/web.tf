resource "aws_instance" "docker" {
  region                      = local.seoul_region
  ami                         = data.aws_ami.amazon_linux_2_arm64.image_id
  availability_zone           = local.seoul_az
  subnet_id                   = aws_subnet.main.id
  disable_api_termination     = true
  disable_api_stop            = true
  ebs_optimized               = true
  iam_instance_profile        = aws_iam_instance_profile.femiwiki.name
  instance_type               = "t4g.small"
  monitoring                  = false
  user_data_replace_on_change = false

  user_data_base64 = base64gzip(templatefile("res/user-data-docker-provider.tftpl", {
    otelcol_install = local.otelcol_install["docker"]
  }))

  vpc_security_group_ids = [
    aws_security_group.web.id,
    aws_security_group.database_client.id,
    aws_security_group.instance_connect.id,
  ]

  root_block_device {
    delete_on_termination = true
    volume_size           = 32
    volume_type           = "gp3"
  }

  credit_specification {
    cpu_credits = "unlimited"
  }

  metadata_options {
    instance_metadata_tags      = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  tags = { Name = "docker" }

  lifecycle {
    ignore_changes = [
      ami,
      user_data,
      user_data_base64,
    ]
  }
}

resource "aws_eip_association" "web" {
  region        = local.seoul_region
  allocation_id = aws_eip.web.id
  instance_id   = aws_instance.docker.id
}
