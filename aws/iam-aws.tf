module "infra_aws" {
  source             = "terraform-aws-modules/iam/aws//modules/iam-role"
  version            = "6.8.2"
  name               = "infra-aws"
  use_name_prefix    = false
  description        = "Allows GitHub Actions workflows of femiwiki/infra to apply the aws workspace."
  enable_github_oidc = true
  # Only the environment, never pull_request: this role can do what Terraform
  # Cloud can, IAM included, and any branch can open a pull request.
  oidc_subjects = ["femiwiki@21275875/infra@188597503:environment:aws"]
}

# Everything this root manages, IAM included.
resource "aws_iam_role_policy" "infra_aws" {
  name   = "InfraAws"
  role   = module.infra_aws.name
  policy = data.aws_iam_policy_document.iac.json
}

module "infra_aws_plan" {
  source             = "terraform-aws-modules/iam/aws//modules/iam-role"
  version            = "6.8.2"
  name               = "infra-aws-plan"
  use_name_prefix    = false
  description        = "Allows GitHub Actions workflows of femiwiki/infra to plan the aws workspace."
  enable_github_oidc = true
  oidc_subjects      = ["femiwiki@21275875/infra@188597503:pull_request"]
  policies           = { ReadOnlyAccess = "arn:aws:iam::aws:policy/ReadOnlyAccess" }
}

# ReadOnlyAccess reads the state already. A plan also takes the lock.
resource "aws_iam_role_policy" "infra_aws_plan" {
  name   = "InfraAwsPlan"
  role   = module.infra_aws_plan.name
  policy = data.aws_iam_policy_document.infra_aws_plan.json
}

data "aws_iam_policy_document" "infra_aws_plan" {
  statement {
    sid       = "StateLock"
    actions   = ["s3:PutObject", "s3:DeleteObject"]
    resources = [for b in local.tfstate_buckets : "${b}/aws/terraform.tfstate.tflock"]
  }

  # ReadOnlyAccess leaves out BCM Data Exports.
  statement {
    sid       = "ReadCostExport"
    actions   = ["bcm-data-exports:GetExport", "bcm-data-exports:ListTagsForResource"]
    resources = [aws_bcmdataexports_export.cost_and_usage.arn]
  }
}
