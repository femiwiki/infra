resource "aws_iam_role" "infra_aws" {
  name               = "infra-aws"
  description        = "Allows GitHub Actions workflows of femiwiki/infra to apply the aws workspace."
  assume_role_policy = data.aws_iam_policy_document.infra_aws_assume_role.json
}

data "aws_iam_policy_document" "infra_aws_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_actions.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    # Only the environment, never pull_request: this role can do what Terraform
    # Cloud can, IAM included, and any branch can open a pull request.
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:femiwiki@21275875/infra@188597503:environment:aws"]
    }
  }
}

# Everything this root manages, IAM included.
resource "aws_iam_role_policy" "infra_aws" {
  name   = "InfraAws"
  role   = aws_iam_role.infra_aws.name
  policy = data.aws_iam_policy_document.iac.json
}

resource "aws_iam_role" "infra_aws_plan" {
  name               = "infra-aws-plan"
  description        = "Allows GitHub Actions workflows of femiwiki/infra to plan the aws workspace."
  assume_role_policy = data.aws_iam_policy_document.infra_aws_plan_assume_role.json
}

data "aws_iam_policy_document" "infra_aws_plan_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_actions.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:femiwiki@21275875/infra@188597503:pull_request"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "infra_aws_plan" {
  role       = aws_iam_role.infra_aws_plan.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess" # AWS managed policy
}

# ReadOnlyAccess reads the state already. A plan also takes the lock.
resource "aws_iam_role_policy" "infra_aws_plan" {
  name   = "InfraAwsPlan"
  role   = aws_iam_role.infra_aws_plan.name
  policy = data.aws_iam_policy_document.infra_aws_plan.json
}

data "aws_iam_policy_document" "infra_aws_plan" {
  statement {
    sid       = "StateLock"
    actions   = ["s3:PutObject", "s3:DeleteObject"]
    resources = ["${aws_s3_bucket.tfstate.arn}/aws/terraform.tfstate.tflock"]
  }

  # ReadOnlyAccess leaves out BCM Data Exports.
  statement {
    sid       = "ReadCostExport"
    actions   = ["bcm-data-exports:GetExport", "bcm-data-exports:ListTagsForResource"]
    resources = [aws_bcmdataexports_export.cost_and_usage.arn]
  }
}
