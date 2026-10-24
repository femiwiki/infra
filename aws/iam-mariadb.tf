module "infra_mariadb" {
  source             = "terraform-aws-modules/iam/aws//modules/iam-role"
  version            = "6.8.2"
  name               = "infra-mariadb"
  use_name_prefix    = false
  description        = "Allows GitHub Actions workflows of femiwiki/infra to apply the mariadb workspace."
  enable_github_oidc = true
  oidc_subjects = [
    "femiwiki@21275875/infra@188597503:environment:mariadb",
  ]
}

resource "aws_iam_role_policy" "infra_mariadb" {
  name   = "InfraMariadb"
  role   = module.infra_mariadb.name
  policy = data.aws_iam_policy_document.infra_mariadb.json
}

data "aws_iam_policy_document" "infra_mariadb" {
  statement {
    sid       = "State"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = [for b in local.tfstate_buckets : "${b}/mariadb/terraform.tfstate*"]
  }

  statement {
    sid       = "StateBucket"
    actions   = ["s3:ListBucket"]
    resources = local.tfstate_buckets
  }

  statement {
    sid     = "ReadLoginPasswords"
    actions = ["ssm:GetParameter"]
    resources = [
      aws_ssm_parameter.mysql_tofu_password.arn,
      aws_ssm_parameter.mariadb_repl_password.arn,
    ]
  }

  statement {
    sid       = "FindInstances"
    actions   = ["ec2:DescribeInstances"]
    resources = ["*"]
  }

  # By role, so a host the swap launches is reachable too.
  statement {
    sid       = "MariadbPortForward"
    actions   = ["ssm:StartSession"]
    resources = ["arn:aws:ec2:${local.seoul_region}:${data.aws_caller_identity.current.account_id}:instance/*"]

    condition {
      test     = "StringEquals"
      variable = "ssm:resourceTag/Role"
      values   = ["database"]
    }
  }

  statement {
    sid       = "MariadbPortForwardDocument"
    actions   = ["ssm:StartSession"]
    resources = ["arn:aws:ssm:${local.seoul_region}::document/AWS-StartPortForwardingSession"]
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

module "infra_mariadb_plan" {
  source             = "terraform-aws-modules/iam/aws//modules/iam-role"
  version            = "6.8.2"
  name               = "infra-mariadb-plan"
  use_name_prefix    = false
  description        = "Allows GitHub Actions workflows of femiwiki/infra to plan the mariadb workspace as the read-only database account."
  enable_github_oidc = true
  oidc_subjects      = ["femiwiki@21275875/infra@188597503:pull_request"]
}

resource "aws_iam_role_policy" "infra_mariadb_plan" {
  name   = "InfraMariadbPlan"
  role   = module.infra_mariadb_plan.name
  policy = data.aws_iam_policy_document.infra_mariadb_plan.json
}

data "aws_iam_policy_document" "infra_mariadb_plan" {
  statement {
    sid       = "ReadState"
    actions   = ["s3:GetObject"]
    resources = [for b in local.tfstate_buckets : "${b}/mariadb/terraform.tfstate"]
  }

  statement {
    sid       = "StateLock"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = [for b in local.tfstate_buckets : "${b}/mariadb/terraform.tfstate.tflock"]
  }

  statement {
    sid       = "StateBucket"
    actions   = ["s3:ListBucket"]
    resources = local.tfstate_buckets
  }

  statement {
    sid     = "ReadLoginPasswords"
    actions = ["ssm:GetParameter"]
    resources = [
      aws_ssm_parameter.mysql_tofu_plan_password.arn,
      aws_ssm_parameter.mariadb_repl_password.arn,
    ]
  }

  statement {
    sid       = "FindInstances"
    actions   = ["ec2:DescribeInstances"]
    resources = ["*"]
  }

  statement {
    sid       = "MariadbPortForward"
    actions   = ["ssm:StartSession"]
    resources = ["arn:aws:ec2:${local.seoul_region}:${data.aws_caller_identity.current.account_id}:instance/*"]

    condition {
      test     = "StringEquals"
      variable = "ssm:resourceTag/Role"
      values   = ["database"]
    }
  }

  statement {
    sid       = "MariadbPortForwardDocument"
    actions   = ["ssm:StartSession"]
    resources = [aws_ssm_document.mariadb_forward.arn]
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
