#
# Edge reconciler delivery + event wiring + alarms.
#
# The edge (aws_instance.docker) is a pet with lifecycle { ignore_changes=[user_data] }
# (ec2.tf), so a user-data edit will NOT update the live box. The script + units are
# delivered Terraform-managed and self-healing via SSM Run Command (the edge already has
# AmazonSSMManagedInstanceCore). region comes from local.region (app-iam.tf); we avoid
# data.aws_region (its `.name` is deprecated in aws ~> 6.x).
#

# --- deliver script + env + units to the edge, idempotently, on a schedule ---
resource "aws_ssm_document" "reconciler_install" {
  name            = "FemiwikiReconcilerInstall"
  document_type   = "Command"
  document_format = "YAML"
  content = yamlencode({
    schemaVersion = "2.2"
    description   = "Install/refresh the Femiwiki edge reconciler"
    mainSteps = [{
      action = "aws:runShellScript"
      name   = "install"
      inputs = {
        runCommand = [
          templatefile("${path.module}/res/install-reconciler.sh.tftpl", {
            reconciler_sh   = file("${path.module}/res/femiwiki-reconciler.sh")
            reconciler_env  = file("${path.module}/res/femiwiki-reconciler.env")
            unit_service    = file("${path.module}/res/femiwiki-reconciler.service")
            unit_timer      = file("${path.module}/res/femiwiki-reconciler.timer")
            unit_caddywatch = file("${path.module}/res/femiwiki-reconciler-caddywatch.service")
          })
        ]
      }
    }]
  })
}

resource "aws_ssm_association" "reconciler_install" {
  name                = aws_ssm_document.reconciler_install.name
  schedule_expression = "rate(30 minutes)" # self-heal drift; first run is immediate on create
  targets {
    key    = "tag:Name"
    values = ["docker"] # the edge instance (aws_instance.docker, tags.Name="docker")
  }
}

# --- alarms (the load-bearing path; reconciler also ships a node_exporter textfile) ---
resource "aws_cloudwatch_metric_alarm" "reconciler_upstreams_low" {
  alarm_name          = "Femiwiki reconciler upstream_count < 1"
  namespace           = "Femiwiki/Reconciler"
  metric_name         = "UpstreamCount"
  statistic           = "Minimum"
  period              = 60
  evaluation_periods  = 2
  datapoints_to_alarm = 2
  threshold           = 1
  comparison_operator = "LessThanThreshold"
  treat_missing_data  = "breaching" # no data == blind == bad
  alarm_actions       = [aws_sns_topic.cloudwatch_alarms_topic.arn]
  ok_actions          = [aws_sns_topic.cloudwatch_alarms_topic.arn]
}

resource "aws_cloudwatch_metric_alarm" "reconciler_stale" {
  alarm_name          = "Femiwiki reconciler stale (no successful pass)"
  namespace           = "Femiwiki/Reconciler"
  metric_name         = "ReconcilerHeartbeat"
  statistic           = "Maximum"
  period              = 60
  evaluation_periods  = 3
  datapoints_to_alarm = 3
  threshold           = 1
  comparison_operator = "LessThanThreshold"
  treat_missing_data  = "breaching"
  alarm_actions       = [aws_sns_topic.cloudwatch_alarms_topic.arn]
  ok_actions          = [aws_sns_topic.cloudwatch_alarms_topic.arn]
}

# --- EventBridge kick: ASG lifecycle transition -> SSM Run Command on the edge (no Lambda) ---
resource "aws_cloudwatch_event_rule" "asg_lifecycle" {
  name        = "femiwiki-asg-lifecycle-reconcile"
  description = "Kick the edge reconciler on ASG launch/terminate lifecycle actions"
  event_pattern = jsonencode({
    source      = ["aws.autoscaling"]
    detail-type = ["EC2 Instance-launch Lifecycle Action", "EC2 Instance-terminate Lifecycle Action"]
    detail      = { AutoScalingGroupName = [aws_autoscaling_group.app.name] }
  })
}

resource "aws_cloudwatch_event_target" "kick_reconciler" {
  rule     = aws_cloudwatch_event_rule.asg_lifecycle.name
  arn      = "arn:aws:ssm:${local.region}::document/AWS-RunShellScript"
  role_arn = aws_iam_role.eventbridge_ssm.arn
  run_command_targets {
    key    = "tag:Name"
    values = ["docker"]
  }
  input = jsonencode({ commands = ["systemctl start --no-block femiwiki-reconciler.service"] })
}

resource "aws_iam_role" "eventbridge_ssm" {
  name               = "femiwiki-eventbridge-ssm-runcommand"
  assume_role_policy = data.aws_iam_policy_document.eventbridge_assume.json
}

data "aws_iam_policy_document" "eventbridge_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "eventbridge_ssm" {
  name   = "send-runshellscript-to-edge"
  role   = aws_iam_role.eventbridge_ssm.id
  policy = data.aws_iam_policy_document.eventbridge_ssm.json
}

data "aws_iam_policy_document" "eventbridge_ssm" {
  statement {
    actions   = ["ssm:SendCommand"]
    resources = ["arn:aws:ssm:${local.region}::document/AWS-RunShellScript"]
  }
  statement {
    actions   = ["ssm:SendCommand"]
    resources = ["arn:aws:ec2:${local.region}:${data.aws_caller_identity.current.account_id}:instance/*"]
    condition {
      test     = "StringEquals"
      variable = "ssm:resourceTag/Name"
      values   = ["docker"]
    }
  }
}
