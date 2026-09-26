resource "aws_iam_role" "infra_docker_seoul" {
  name               = "infra-docker-seoul"
  description        = "Allows GitHub Actions workflows of femiwiki/infra to plan and apply the docker-seoul workspace."
  assume_role_policy = data.aws_iam_policy_document.infra_docker_seoul_assume_role.json
}

data "aws_iam_policy_document" "infra_docker_seoul_assume_role" {
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
        "repo:femiwiki@21275875/infra@188597503:environment:docker-seoul",
      ]
    }
  }
}

resource "aws_iam_role_policy" "infra_docker_seoul" {
  name   = "InfraDockerSeoul"
  role   = aws_iam_role.infra_docker_seoul.name
  policy = data.aws_iam_policy_document.infra_docker_seoul.json
}

data "aws_iam_policy_document" "infra_docker_seoul" {
  statement {
    sid       = "State"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["${aws_s3_bucket.tfstate.arn}/docker-seoul/terraform.tfstate*"]
  }

  statement {
    sid       = "StateBucket"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.tfstate.arn]
  }

  statement {
    sid       = "FindInstances"
    actions   = ["ec2:DescribeInstances", "ec2:DescribeInstanceTypes"]
    resources = ["*"]
  }

  statement {
    sid     = "DockerPortForward"
    actions = ["ssm:StartSession"]
    resources = [
      aws_instance.docker_seoul.arn,
      "arn:aws:ssm:${local.seoul_region}::document/AWS-StartPortForwardingSession",
    ]
  }

  statement {
    sid       = "OwnSessions"
    actions   = ["ssm:TerminateSession", "ssm:ResumeSession"]
    resources = ["arn:aws:ssm:*:*:session/$${aws:userid}-*"]
  }
}
