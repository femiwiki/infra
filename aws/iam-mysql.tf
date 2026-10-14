resource "aws_iam_role" "infra_mysql" {
  name               = "infra-mysql"
  description        = "Allows GitHub Actions workflows of femiwiki/infra to plan and apply the mysql workspace."
  assume_role_policy = data.aws_iam_policy_document.infra_mysql_assume_role.json
}

data "aws_iam_policy_document" "infra_mysql_assume_role" {
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
        "repo:femiwiki@21275875/infra@188597503:environment:mysql",
      ]
    }
  }
}

resource "aws_iam_role_policy" "infra_mysql" {
  name   = "InfraMysql"
  role   = aws_iam_role.infra_mysql.name
  policy = data.aws_iam_policy_document.infra_mysql.json
}

data "aws_iam_policy_document" "infra_mysql" {
  statement {
    sid       = "State"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = [for b in local.tfstate_buckets : "${b}/mysql/terraform.tfstate*"]
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

  statement {
    sid     = "MariadbPortForward"
    actions = ["ssm:StartSession"]
    resources = concat(
      [for instance in aws_instance.database : instance.arn],
      ["arn:aws:ssm:${local.seoul_region}::document/AWS-StartPortForwardingSession"],
    )
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
