#
# Backend tier: a small ASG of the FrankenPHP image (desired=1, transient 2 during
# a deploy), t4g.small ARM, AZ ap-northeast-1a, plain HTTP :8080, reachable only
# from the edge SG. Zero-downtime deploys = launch-before-terminate instance refresh
# gated on a real /healthz-ready via the LAUNCHING lifecycle hook.
#

variable "app_image" {
  type        = string
  description = "FrankenPHP backend image:tag. THIS is the deploy lever: bump it -> new launch template version -> auto instance refresh. Pin by digest in production."
  default     = "ghcr.io/femiwiki/femiwiki-frankenphp:2026-06-28"
}

variable "app_frankenphp_num_threads" {
  type        = number
  description = "FrankenPHP classic-mode fixed thread pool. RAM: threads*128M + 512M opcache must fit the t4g.small (2GB) -> keep <= ~8. DB: nodes*threads*connects_per_request must stay under MariaDB max_connections."
  default     = 8
}

variable "app_cpu_credits" {
  type        = string
  description = "t4g credit mode. 'unlimited' avoids CPU-throttle brownouts on the single serving node (matches edge/db); 'standard' is cheaper but can throttle under sustained load."
  default     = "unlimited"
}

locals {
  launch_hook_name    = "femiwiki-app-launch"
  terminate_hook_name = "femiwiki-app-terminate"
}

#
# (1) Launch template: t4g.small arm64, the backend SG + the DB-client SG, IMDSv2
#     with instance tags exposed, and the self-health-gating user-data.
#
resource "aws_launch_template" "app" {
  name_prefix            = "femiwiki-app-"
  description            = "Femiwiki FrankenPHP backend node"
  image_id               = data.aws_ami.amazon_linux_2_arm64.image_id # AL2023 minimal arm64 host; runs Docker
  instance_type          = "t4g.small"
  ebs_optimized          = true
  update_default_version = true

  iam_instance_profile {
    arn = aws_iam_instance_profile.app.arn
  }

  # Backend SG (ingress 8080 from the edge only, egress all) + the DB-client SG
  # (grants 3306 to the DB via the existing mysql_ingress_mediawiki rule). No EIP/NAT:
  # the node needs a public IP to reach SSM/S3/SES/Grafana Cloud/GHCR. We assign it
  # EXPLICITLY here rather than relying on the (unmanaged) default-subnet
  # map_public_ip_on_launch, so egress cannot silently break if that attribute flips.
  # SGs move into this block: vpc_security_group_ids cannot coexist with
  # network_interfaces on the same launch template.
  network_interfaces {
    device_index                = 0
    associate_public_ip_address = true
    delete_on_termination       = true
    security_groups = [
      aws_security_group.app.id,
      aws_security_group.mediawiki.id,
    ]
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required" # IMDSv2 only
    instance_metadata_tags      = "enabled"  # exposes aws:autoscaling:groupName to user-data
    http_put_response_hop_limit = 2          # docker container -> IMDS (host net is hop 1; bridge would be 2)
  }

  credit_specification {
    cpu_credits = var.app_cpu_credits
  }

  monitoring {
    enabled = false
  }

  block_device_mappings {
    device_name = "/dev/xvda" # AL2023 root device
    ebs {
      volume_size           = 30
      volume_type           = "gp3"
      delete_on_termination = true
      encrypted             = true
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags          = { Name = "femiwiki-app" }
  }

  tag_specifications {
    resource_type = "volume"
    tags          = { Name = "femiwiki-app" }
  }

  user_data = base64encode(templatefile("${path.module}/res/user-data-app.sh.tftpl", {
    image                  = var.app_image
    region                 = local.region
    frankenphp_num_threads = var.app_frankenphp_num_threads
    launch_hook_name       = local.launch_hook_name
    mysql_endpoint         = "${aws_instance.database.private_ip}:3306"
    edge_private_ip        = aws_instance.docker.private_ip
    mediawiki_server       = "https://femiwiki.com"
    hotfix_snippet         = file("${path.module}/res/Hotfix.php")

    # Non-secret Alloy fields stay templated; the two passwords are sentinels that
    # the node substitutes at boot from SSM (app-ssm.tf). Same body as the edge.
    alloy_config = templatefile("${path.module}/res/config.alloy.tftpl", {
      name                = "app"
      prometheus_endpoint = "https://prometheus-prod-49-prod-ap-northeast-0.grafana.net/api/prom/push"
      prometheus_username = "1835631"
      prometheus_password = "@@PROMETHEUS_PASSWORD@@"
      loki_endpoint       = "https://logs-prod-030.grafana.net/loki/api/v1/push"
      loki_username       = "1017101"
      loki_password       = "@@LOKI_PASSWORD@@"
    })
  }))

  lifecycle {
    create_before_destroy = true
  }

  tags = { Name = "femiwiki-app" }
}

#
# (2) Auto Scaling group: desired=1/min=1/max=2 (room for the deploy surge), AZ-a,
#     EC2 health checks (no ELB), launch-before-terminate maintenance policy, and the
#     launch + terminate lifecycle hooks.
#
resource "aws_autoscaling_group" "app" {
  name                = local.app_asg_name
  min_size            = 1
  max_size            = 2 # desired(1) + 1 surge for max_healthy_percentage=200
  desired_capacity    = 1
  vpc_zone_identifier = [aws_default_subnet.default["a"].id] # single AZ 1a, same as the DB

  # No ELB/ALB/NLB in this architecture: ASG only watches EC2 status checks. App
  # health is enforced elsewhere (launch hook gate + edge Caddy active checks +
  # the node watchdog's SetInstanceHealth).
  health_check_type         = "EC2"
  health_check_grace_period = 120
  default_instance_warmup   = 120
  wait_for_capacity_timeout = "15m" # the launch hook delays InService until /healthz-ready passes
  capacity_rebalance        = false

  launch_template {
    id = aws_launch_template.app.id
    # latest_version (the resource ATTRIBUTE, an integer) -> a tag bump produces a new
    # LT version, Terraform sees the integer change, the ASG updates, and the refresh
    # fires. Do NOT use the literal "$Latest": a refresh does not start with "$Latest".
    version = aws_launch_template.app.latest_version
  }

  # Launch-before-terminate: keep 100% healthy at all times, allow surging to 200%
  # so the new node is InService+healthy BEFORE the old one is terminated.
  instance_maintenance_policy {
    min_healthy_percentage = 100
    max_healthy_percentage = 200
  }

  # LAUNCHING gate: the instance sits in Pending:Wait until user-data confirms a real
  # /healthz-ready (then complete-lifecycle-action CONTINUE). If it never gets healthy
  # within the heartbeat, DefaultResult=ABANDON terminates it and auto_rollback reverts.
  # heartbeat_timeout covers image pull + boot + first ready; user-data also extends it
  # with record-lifecycle-action-heartbeat.
  initial_lifecycle_hook {
    name                 = local.launch_hook_name
    lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"
    default_result       = "ABANDON"
    heartbeat_timeout    = 600
  }

  # TERMINATING drain: the instance sits in Terminating:Wait so the EDGE reconciler can
  # remove it from the Caddy upstreams (add-before-remove) and confirm drain, then call
  # complete-lifecycle-action CONTINUE. DefaultResult=CONTINUE so a reconciler outage
  # cannot wedge a termination; heartbeat_timeout >= reconciler convergence + drain.
  initial_lifecycle_hook {
    name                 = local.terminate_hook_name
    lifecycle_transition = "autoscaling:EC2_INSTANCE_TERMINATING"
    default_result       = "CONTINUE"
    heartbeat_timeout    = 180
  }

  # (3) A launch-template change always triggers a Rolling refresh, so no explicit `triggers`
  #     is set (listing "launch_template" is redundant and warns). auto_rollback reverts a
  #     failed refresh to the prior LT version. min/max healthy mirror the maintenance policy.
  #
  # ROLLBACK RUNBOOK (avoid the rollback loop): version = latest_version, so a bad deploy
  # makes LT vN (latest) and auto_rollback reverts the ASG to vN-1, but the config still
  # resolves to vN. Re-applying Terraform RE-TRIGGERS the same failed refresh. To recover
  # you MUST revert var.app_image to the last-good tag/digest (which produces a NEW good LT
  # version), then apply. Do not just click apply on the failed run. Pin app_image by
  # @sha256: digest in prod so rollback state and config converge on a known artifact (D10).
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 100
      max_healthy_percentage = 200
      auto_rollback          = true
      skip_matching          = false
      instance_warmup        = 120
    }
  }

  tag {
    key                 = "Name"
    value               = "femiwiki-app"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity] # do not fight the transient deploy surge / manual scaling
  }
}
