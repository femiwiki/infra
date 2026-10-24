module "infra_docker" {
  source             = "terraform-aws-modules/iam/aws//modules/iam-role"
  version            = "6.8.2"
  name               = "infra-docker"
  use_name_prefix    = false
  description        = "Allows GitHub Actions workflows of femiwiki/infra to apply the docker workspace."
  enable_github_oidc = true
  oidc_subjects = [
    "femiwiki@21275875/infra@188597503:environment:docker",
  ]
}

resource "aws_iam_role_policy" "infra_docker" {
  name   = "InfraDocker"
  role   = module.infra_docker.name
  policy = data.aws_iam_policy_document.infra_docker.json
}

data "aws_iam_policy_document" "infra_docker" {
  statement {
    sid       = "State"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = [for b in local.tfstate_buckets : "${b}/docker/terraform.tfstate*"]
  }

  statement {
    sid       = "ReadAwsOutputs"
    actions   = ["s3:GetObject"]
    resources = [for b in local.tfstate_buckets : "${b}/aws/terraform.tfstate"]
  }

  statement {
    sid       = "ReadGcpOutputs"
    actions   = ["s3:GetObject"]
    resources = [for b in local.tfstate_buckets : "${b}/gcp/terraform.tfstate"]
  }

  statement {
    sid       = "StateBucket"
    actions   = ["s3:ListBucket"]
    resources = local.tfstate_buckets
  }

  statement {
    sid       = "FindInstances"
    actions   = ["ec2:DescribeInstances", "ec2:DescribeInstanceTypes"]
    resources = ["*"]
  }

  statement {
    sid       = "ReadMediawikiDbPassword"
    actions   = ["ssm:GetParameter"]
    resources = [aws_ssm_parameter.secret["/mysql/users/mediawiki/password"].arn]
  }

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
      # SSM names a session after the role session name, GitHubActions-<random>,
      # while aws:userid for an assumed role expands to <role id>:GitHubActions,
      # so the pattern below never matches one of these.
      "arn:aws:ssm:*:*:session/GitHubActions-*",
      "arn:aws:ssm:*:*:session/$${aws:userid}-*",
    ]
  }
}

module "infra_docker_plan" {
  source             = "terraform-aws-modules/iam/aws//modules/iam-role"
  version            = "6.8.2"
  name               = "infra-docker-plan"
  use_name_prefix    = false
  description        = "Allows GitHub Actions workflows of femiwiki/infra to plan the docker workspace through the read-only Docker API."
  enable_github_oidc = true
  oidc_subjects      = ["femiwiki@21275875/infra@188597503:pull_request"]
}

resource "aws_iam_role_policy" "infra_docker_plan" {
  name   = "InfraDockerPlan"
  role   = module.infra_docker_plan.name
  policy = data.aws_iam_policy_document.infra_docker_plan.json
}

data "aws_iam_policy_document" "infra_docker_plan" {
  statement {
    sid       = "ReadState"
    actions   = ["s3:GetObject"]
    resources = [for b in local.tfstate_buckets : "${b}/docker/terraform.tfstate"]
  }

  statement {
    sid       = "StateLock"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = [for b in local.tfstate_buckets : "${b}/docker/terraform.tfstate.tflock"]
  }

  statement {
    sid       = "ReadAwsOutputs"
    actions   = ["s3:GetObject"]
    resources = [for b in local.tfstate_buckets : "${b}/aws/terraform.tfstate"]
  }

  statement {
    sid       = "ReadGcpOutputs"
    actions   = ["s3:GetObject"]
    resources = [for b in local.tfstate_buckets : "${b}/gcp/terraform.tfstate"]
  }

  statement {
    sid       = "StateBucket"
    actions   = ["s3:ListBucket"]
    resources = local.tfstate_buckets
  }

  statement {
    sid       = "FindInstances"
    actions   = ["ec2:DescribeInstances", "ec2:DescribeInstanceTypes"]
    resources = ["*"]
  }

  statement {
    sid       = "ReadMediawikiDbPassword"
    actions   = ["ssm:GetParameter"]
    resources = [aws_ssm_parameter.secret["/mysql/users/mediawiki/password"].arn]
  }

  statement {
    sid     = "ReadOnlyDockerApiForward"
    actions = ["ssm:StartSession"]
    resources = [
      aws_instance.docker.arn,
      aws_ssm_document.docker_api_readonly_forward.arn,
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
