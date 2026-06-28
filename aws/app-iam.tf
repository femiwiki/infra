#
# IAM for the backend ASG nodes and for the edge reconciler.
#
# Shared identifiers (account id resolved at plan time; region is pinned for the
# whole workspace in base.tf). Using the ASG NAME (not the resource attribute) in
# the lifecycle ARN avoids a role -> profile -> launch_template -> ASG -> role cycle.
#
data "aws_caller_identity" "current" {}

locals {
  region           = "ap-northeast-1"
  app_asg_name     = "femiwiki-app"
  app_asg_arn_glob = "arn:aws:autoscaling:${local.region}:${data.aws_caller_identity.current.account_id}:autoScalingGroup:*:autoScalingGroupName/${local.app_asg_name}"
}

#
# Backend ASG node role + instance profile (none existed before).
# Reuses the same EC2 assume-role policy as aws_iam_role.femiwiki / .database.
#
resource "aws_iam_role" "app" {
  name               = "App"
  description        = "Femiwiki backend ASG nodes (FrankenPHP)"
  assume_role_policy = data.aws_iam_policy_document.instance_assume_role.json
}

resource "aws_iam_instance_profile" "app" {
  name = "App"
  role = aws_iam_role.app.name
}

# Runtime secret fetch (replaces the edge's plan-time data.aws_ssm_parameters_by_path
# + docker env injection). The node calls `aws ssm get-parameter --with-decryption`
# at boot for exactly the /mediawiki/* and /mysql/* keys used in docker/container.tf,
# plus the new /alloy/* creds (app-ssm.tf).
data "aws_iam_policy_document" "app_node" {
  statement {
    sid = "SsmGetAppSecrets"
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath",
    ]
    resources = [
      "arn:aws:ssm:${local.region}:${data.aws_caller_identity.current.account_id}:parameter/mediawiki/*",
      "arn:aws:ssm:${local.region}:${data.aws_caller_identity.current.account_id}:parameter/mysql/*",
      "arn:aws:ssm:${local.region}:${data.aws_caller_identity.current.account_id}:parameter/alloy/*",
    ]
  }

  # Only needed if any of the above are SecureString (site_key / passwords are).
  # Scoped to SSM's use of KMS so it cannot decrypt arbitrary ciphertext.
  statement {
    sid       = "KmsDecryptViaSsm"
    actions   = ["kms:Decrypt"]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["ssm.${local.region}.amazonaws.com"]
    }
  }

  # Self-signalling for the LAUNCHING lifecycle hook (the health gate) and the
  # container watchdog (SetInstanceHealth Unhealthy -> ASG replaces the node).
  statement {
    sid = "LifecycleSelfSignal"
    actions = [
      "autoscaling:CompleteLifecycleAction",
      "autoscaling:RecordLifecycleActionHeartbeat",
      "autoscaling:SetInstanceHealth",
    ]
    resources = [local.app_asg_arn_glob]
  }
}

resource "aws_iam_policy" "app_node" {
  name        = "AppNode"
  description = "SSM secret fetch + self lifecycle signalling for backend ASG nodes"
  policy      = data.aws_iam_policy_document.app_node.json
}

resource "aws_iam_role_policy_attachment" "app_node" {
  role       = aws_iam_role.app.name
  policy_arn = aws_iam_policy.app_node.arn
}

# MediaWiki S3 upload backend (same policy the edge fastcgi used).
resource "aws_iam_role_policy_attachment" "app_amazon_s3_access" {
  role       = aws_iam_role.app.name
  policy_arn = aws_iam_policy.amazon_s3_access.arn
}

# Session Manager shell + CloudWatch agent (parity with the other roles).
# Deliberately NOT attached: route53, access_caddycerts, download_secrets,
# upload_backup (no TLS/Caddy/backup/S3-secrets role on the backend).
resource "aws_iam_role_policy_attachment" "app_managed_policies" {
  for_each = toset([
    "AmazonSSMManagedInstanceCore",
    "CloudWatchAgentServerPolicy",
  ])
  role       = aws_iam_role.app.name
  policy_arn = "arn:aws:iam::aws:policy/${each.key}"
}

#
# Reconciler permissions, attached to the EXISTING edge role (aws_iam_role.femiwiki).
# The edge daemon resolves InService+Healthy ASG instances -> private IPs (Caddy
# upstreams) and completes/drains the TERMINATING hook. Describe* has no
# resource-level support (Resource "*"); the write actions are scoped to the ASG.
#
data "aws_iam_policy_document" "reconciler" {
  statement {
    sid = "DescribeFleet"
    actions = [
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeLifecycleHooks",
      "ec2:DescribeInstances",
    ]
    resources = ["*"]
  }

  statement {
    sid = "DrainAndGate"
    actions = [
      "autoscaling:CompleteLifecycleAction",
      "autoscaling:RecordLifecycleActionHeartbeat",
      "autoscaling:SetInstanceHealth",
    ]
    resources = [local.app_asg_arn_glob]
  }
}

resource "aws_iam_policy" "reconciler" {
  name        = "Reconciler"
  description = "Edge reconciler: read ASG fleet, drain/gate the terminate hook"
  policy      = data.aws_iam_policy_document.reconciler.json
}

resource "aws_iam_role_policy_attachment" "femiwiki_reconciler" {
  role       = aws_iam_role.femiwiki.name
  policy_arn = aws_iam_policy.reconciler.arn
}
