resource "aws_iam_role" "infra_gcp" {
  name               = "infra-gcp"
  description        = "Allows GitHub Actions workflows of femiwiki/infra to plan and apply the gcp workspace."
  assume_role_policy = data.aws_iam_policy_document.infra_gcp_assume_role.json
}

data "aws_iam_policy_document" "infra_gcp_assume_role" {
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
      values = [
        "repo:femiwiki@21275875/infra@188597503:pull_request",
        "repo:femiwiki@21275875/infra@188597503:environment:gcp",
      ]
    }
  }
}

resource "aws_iam_role_policy" "infra_gcp" {
  name   = "InfraGcp"
  role   = aws_iam_role.infra_gcp.name
  policy = data.aws_iam_policy_document.infra_gcp.json
}

data "aws_iam_policy_document" "infra_gcp" {
  statement {
    sid       = "State"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["${aws_s3_bucket.tfstate.arn}/gcp/terraform.tfstate*"]
  }

  statement {
    sid       = "StateBucket"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.tfstate.arn]
  }

  statement {
    sid       = "AwsOutputs"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.tfstate.arn}/aws/terraform.tfstate"]
  }
}
