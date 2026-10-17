resource "aws_iam_role" "infra_mariadb" {
  name               = "infra-mariadb"
  description        = "Allows GitHub Actions workflows of femiwiki/infra to plan and apply the mariadb workspace."
  assume_role_policy = data.aws_iam_policy_document.infra_mariadb_assume_role.json
}

data "aws_iam_policy_document" "infra_mariadb_assume_role" {
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
        "repo:femiwiki@21275875/infra@188597503:environment:mariadb",
      ]
    }
  }
}

resource "aws_iam_role_policy" "infra_mariadb" {
  name   = "InfraMariadb"
  role   = aws_iam_role.infra_mariadb.name
  policy = data.aws_iam_policy_document.infra_mariadb.json
}

data "aws_iam_policy_document" "infra_mariadb" {
  statement {
    sid       = "State"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = [for b in local.tfstate_buckets : "${b}/mariadb/terraform.tfstate*"]
  }

  statement {
    sid       = "ReadAwsOutputs"
    actions   = ["s3:GetObject"]
    resources = [for b in local.tfstate_buckets : "${b}/aws/terraform.tfstate"]
  }

  statement {
    sid       = "StateBucket"
    actions   = ["s3:ListBucket"]
    resources = local.tfstate_buckets
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
