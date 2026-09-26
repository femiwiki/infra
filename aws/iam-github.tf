resource "aws_iam_role" "infra_github" {
  name               = "infra-github"
  description        = "Allows GitHub Actions workflows of femiwiki/infra to plan and apply the github workspace."
  assume_role_policy = data.aws_iam_policy_document.infra_github_assume_role.json
}

data "aws_iam_policy_document" "infra_github_assume_role" {
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
        "repo:femiwiki@21275875/infra@188597503:environment:github",
      ]
    }
  }
}

resource "aws_iam_role_policy" "infra_github" {
  name   = "InfraGithub"
  role   = aws_iam_role.infra_github.name
  policy = data.aws_iam_policy_document.infra_github.json
}

data "aws_iam_policy_document" "infra_github" {
  statement {
    sid       = "State"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["${aws_s3_bucket.tfstate.arn}/github/terraform.tfstate*"]
  }

  statement {
    sid       = "StateBucket"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.tfstate.arn]
  }
}
