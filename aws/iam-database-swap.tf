module "database_swap" {
  source          = "terraform-aws-modules/iam/aws//modules/iam-role"
  version         = "6.8.2"
  name            = "database-swap"
  use_name_prefix = false
  description     = "Allows the database swap workflow of femiwiki/infra to replace the primary database host."
  # The replica job waits hours for the dump to restore
  max_session_duration = 18000
  enable_github_oidc   = true
  oidc_subjects = [
    "femiwiki@21275875/infra@188597503:environment:database-replica",
    "femiwiki@21275875/infra@188597503:environment:database",
  ]
}

resource "aws_iam_role_policy" "database_swap" {
  name   = "DatabaseSwap"
  role   = module.database_swap.name
  policy = data.aws_iam_policy_document.database_swap.json
}

data "aws_iam_policy_document" "database_swap" {
  statement {
    sid = "Describe"
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeNetworkInterfaces",
      "ssm:DescribeInstanceInformation",
      "ssm:GetCommandInvocation",
    ]
    resources = ["*"]
  }

  statement {
    sid       = "Capacity"
    actions   = ["autoscaling:SetDesiredCapacity", "autoscaling:SetInstanceProtection"]
    resources = [aws_autoscaling_group.database.arn]
  }

  statement {
    sid       = "ServerId"
    actions   = ["ssm:GetParameter", "ssm:PutParameter"]
    resources = [aws_ssm_parameter.mariadb_next_server_id.arn]
  }

  # Every action on a host is limited to the database role, so a host the ASG
  # launches is covered and nothing else is.
  statement {
    sid       = "DatabaseCommands"
    actions   = ["ssm:SendCommand"]
    resources = ["arn:aws:ec2:${local.seoul_region}:${data.aws_caller_identity.current.account_id}:instance/*"]

    condition {
      test     = "StringEquals"
      variable = "ssm:resourceTag/Role"
      values   = ["database"]
    }
  }

  statement {
    sid       = "ShellDocument"
    actions   = ["ssm:SendCommand"]
    resources = ["arn:aws:ssm:${local.seoul_region}::document/AWS-RunShellScript"]
  }

  statement {
    sid       = "MoveInterface"
    actions   = ["ec2:AttachNetworkInterface", "ec2:DetachNetworkInterface"]
    resources = ["arn:aws:ec2:${local.seoul_region}:${data.aws_caller_identity.current.account_id}:instance/*"]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Role"
      values   = ["database"]
    }
  }

  # The interface carries no Role tag, so it is named alone
  statement {
    sid       = "MoveThisInterface"
    actions   = ["ec2:AttachNetworkInterface", "ec2:DetachNetworkInterface"]
    resources = [aws_network_interface.database.arn]
  }

  statement {
    sid       = "Tags"
    actions   = ["ec2:CreateTags"]
    resources = ["arn:aws:ec2:${local.seoul_region}:${data.aws_caller_identity.current.account_id}:instance/*"]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Role"
      values   = ["database"]
    }

    condition {
      test     = "ForAllValues:StringEquals"
      variable = "aws:TagKeys"
      values   = ["Name", "MysqlBackup", "Swap"]
    }
  }

  # The docker workspace, applied with ProxySQL on and then off
  statement {
    sid       = "DockerState"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = [for b in local.tfstate_buckets : "${b}/docker/terraform.tfstate*"]
  }

  statement {
    sid     = "ReadOutputs"
    actions = ["s3:GetObject"]
    resources = flatten([for b in local.tfstate_buckets : [
      "${b}/aws/terraform.tfstate",
      "${b}/gcp/terraform.tfstate",
    ]])
  }

  statement {
    sid       = "StateBucket"
    actions   = ["s3:ListBucket"]
    resources = local.tfstate_buckets
  }

  # The docker daemon and ProxySQL's admin port
  statement {
    sid     = "DockerPortForward"
    actions = ["ssm:StartSession"]
    resources = [
      aws_instance.docker.arn,
      "arn:aws:ssm:${local.seoul_region}::document/AWS-StartPortForwardingSession",
    ]
  }

  statement {
    sid     = "OwnSessions"
    actions = ["ssm:TerminateSession", "ssm:ResumeSession"]
    resources = [
      "arn:aws:ssm:*:*:session/GitHubActions-*",
      "arn:aws:ssm:*:*:session/$${aws:userid}-*",
    ]
  }
}
