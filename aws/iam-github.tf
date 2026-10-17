module "infra_github" {
  source             = "terraform-aws-modules/iam/aws//modules/iam-role"
  version            = "6.8.2"
  name               = "infra-github"
  use_name_prefix    = false
  description        = "Allows GitHub Actions workflows of femiwiki/infra to plan and apply the github workspace."
  enable_github_oidc = true
  oidc_subjects = [
    "femiwiki@21275875/infra@188597503:pull_request",
    "femiwiki@21275875/infra@188597503:environment:github",
  ]
}

moved {
  from = aws_iam_role.infra_github
  to   = module.infra_github.aws_iam_role.this[0]
}

resource "aws_iam_role_policy" "infra_github" {
  name   = "InfraGithub"
  role   = module.infra_github.name
  policy = data.aws_iam_policy_document.infra_github.json
}

data "aws_iam_policy_document" "infra_github" {
  statement {
    sid       = "State"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = [for b in local.tfstate_buckets : "${b}/github/terraform.tfstate*"]
  }

  statement {
    sid       = "StateBucket"
    actions   = ["s3:ListBucket"]
    resources = local.tfstate_buckets
  }
}
