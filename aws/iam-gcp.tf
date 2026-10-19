module "infra_gcp" {
  source             = "terraform-aws-modules/iam/aws//modules/iam-role"
  version            = "6.8.2"
  name               = "infra-gcp"
  use_name_prefix    = false
  description        = "Allows GitHub Actions workflows of femiwiki/infra to plan and apply the gcp workspace."
  enable_github_oidc = true
  oidc_subjects = [
    "femiwiki@21275875/infra@188597503:pull_request",
    "femiwiki@21275875/infra@188597503:environment:gcp",
  ]
}

resource "aws_iam_role_policy" "infra_gcp" {
  name   = "InfraGcp"
  role   = module.infra_gcp.name
  policy = data.aws_iam_policy_document.infra_gcp.json
}

data "aws_iam_policy_document" "infra_gcp" {
  statement {
    sid       = "State"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = [for b in local.tfstate_buckets : "${b}/gcp/terraform.tfstate*"]
  }

  statement {
    sid       = "StateBucket"
    actions   = ["s3:ListBucket"]
    resources = local.tfstate_buckets
  }

  statement {
    sid       = "AwsOutputs"
    actions   = ["s3:GetObject"]
    resources = [for b in local.tfstate_buckets : "${b}/aws/terraform.tfstate"]
  }
}
