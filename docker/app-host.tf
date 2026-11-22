# The app hosts, listed in app-hosts.json; femiwiki/femiwiki#577 has how a host
# is replaced. aws/ hands over what a launch needs as app_host_launch.
locals {
  app_hosts = jsondecode(file("${path.module}/app-hosts.json"))
  launch    = data.terraform_remote_state.aws.outputs.app_host_launch

  # Each host's Docker API, forwarded by the workflows to its own runner port
  docker_hosts = { for key in local.app_hosts.containers : key => "tcp://${var.docker_gateway}:${local.app_hosts.hosts[key].port}" }
}

resource "aws_instance" "app" {
  for_each = local.app_hosts.hosts

  ami                         = local.launch.ami
  availability_zone           = local.launch.availability_zone
  subnet_id                   = local.launch.subnet_id
  disable_api_termination     = true
  disable_api_stop            = true
  ebs_optimized               = true
  iam_instance_profile        = local.launch.iam_instance_profile
  instance_type               = "t4g.small"
  monitoring                  = false
  user_data_replace_on_change = false
  user_data_base64            = local.launch.user_data_base64
  vpc_security_group_ids      = local.launch.vpc_security_group_ids

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

  # The SSM associations target Role; the workflows find a host by HostKey
  tags = {
    Name         = "docker"
    Role         = "app"
    DockerTarget = "true"
    HostKey      = each.key
  }

  lifecycle {
    ignore_changes = [
      ami,
      user_data,
      user_data_base64,
    ]
  }
}

# Only the hosts marked eip keep one: associating an EIP with a running host
# replaces the public IP it booted with, which a plan cannot know.
resource "aws_eip" "app" {
  for_each = { for key, host in local.app_hosts.hosts : key => host if try(host.eip, false) }

  domain = "vpc"

  tags = { Name = "femiwiki.com" }
}

resource "aws_eip_association" "app" {
  for_each = aws_eip.app

  allocation_id = each.value.id
  instance_id   = aws_instance.app[each.key].id
}

# The name CloudFront connects to. Only CloudFront resolves it, so a short TTL
# costs nothing and lets a new address take over within a minute.
resource "aws_route53_record" "cloudfront_origin" {
  name    = "cloudfront-origin.femiwiki.com"
  type    = "A"
  zone_id = data.terraform_remote_state.aws.outputs.femiwiki_com_zone_id
  records = [aws_instance.app[local.app_hosts.serving].public_ip]
  ttl     = 60
}
