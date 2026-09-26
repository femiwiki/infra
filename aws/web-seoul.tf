locals {
  alloy_install_docker_seoul = replace(
    replace(file("res/install-alloy-config.sh"), "__REGION__", local.seoul_region),
    "__CONFIG__",
    templatefile("res/config.alloy.tftpl", merge(local.alloy_grafana, { name = "femiwiki-seoul" }))
  )
}

resource "aws_instance" "docker_seoul" {
  region                      = local.seoul_region
  ami                         = data.aws_ami.amazon_linux_2_arm64_seoul.image_id
  availability_zone           = local.seoul_az
  subnet_id                   = aws_subnet.seoul.id
  disable_api_termination     = false
  disable_api_stop            = false
  ebs_optimized               = true
  iam_instance_profile        = aws_iam_instance_profile.femiwiki.name
  instance_type               = "t4g.small"
  monitoring                  = false
  user_data_replace_on_change = false

  user_data = templatefile("res/user-data-docker-provider.tftpl", {
    alloy_install = local.alloy_install_docker_seoul
  })

  vpc_security_group_ids = [
    aws_security_group.web_seoul.id,
    aws_security_group.database_client_seoul.id,
    aws_security_group.instance_connect_seoul.id,
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

  tags = { Name = "docker-seoul" }

  lifecycle {
    ignore_changes = [
      ami,
      user_data,
    ]
  }
}

resource "aws_eip_association" "seoul" {
  region        = local.seoul_region
  allocation_id = aws_eip.seoul.id
  instance_id   = aws_instance.docker_seoul.id
}
