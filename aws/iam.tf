locals {
  programmatic_users = [
    "femiwiki-email",
  ]
}

resource "aws_iam_account_password_policy" "strict" {
  allow_users_to_change_password = true
  minimum_password_length        = 14
}

resource "aws_iam_openid_connect_provider" "github_actions" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["1b511abead59c6ce207077c0bf0e0043b1382612"]
}

# Lets IAM principals call sts:GetWebIdentityToken for JWTs that outside services trust
resource "aws_iam_outbound_web_identity_federation" "this" {}

#
# IAM Users
#
resource "aws_iam_user" "programmatic_users" {
  for_each = toset(local.programmatic_users)
  name     = each.key
}

resource "aws_iam_user_policy" "ses_sending_access" {
  name   = "AmazonSesSendingAccess"
  user   = "femiwiki-email"
  policy = data.aws_iam_policy_document.ses_sending_access.json
}


#
# IAM Groups
#
resource "aws_iam_group" "admin" {
  name = "Admin"
}

resource "aws_iam_group_policy_attachment" "admin_permission" {
  group      = aws_iam_group.admin.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess" # AWS managed policy
}

resource "aws_iam_group_policy_attachment" "admin_mfa" {
  group      = aws_iam_group.admin.name
  policy_arn = aws_iam_policy.force_mfa.arn
}

resource "aws_iam_group" "readonly" {
  name = "ReadOnly"
}

resource "aws_iam_group_policy_attachment" "readonly_permission" {
  group      = aws_iam_group.readonly.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess" # AWS managed policy
}

resource "aws_iam_group_policy_attachment" "readonly_mfa" {
  group      = aws_iam_group.readonly.name
  policy_arn = aws_iam_policy.force_mfa.arn
}


# IAM Roles
module "github_lambda" {
  source             = "terraform-aws-modules/iam/aws//modules/iam-role"
  version            = "6.8.2"
  name               = "github-lambda"
  use_name_prefix    = false
  description        = "Allows GitHub Actions workflows of femiwiki/lambda to deploy its functions."
  enable_github_oidc = true
  oidc_subjects = [
    "femiwiki/lambda:ref:refs/heads/main",
  ]
}

moved {
  from = aws_iam_role.github_lambda
  to   = module.github_lambda.aws_iam_role.this[0]
}

resource "aws_iam_role_policy" "github_lambda" {
  name   = "GithubLambda"
  role   = module.github_lambda.name
  policy = data.aws_iam_policy_document.github_lambda.json
}

module "femiwiki_github_io" {
  source             = "terraform-aws-modules/iam/aws//modules/iam-role"
  version            = "6.8.2"
  name               = "femiwiki-github-io"
  use_name_prefix    = false
  description        = "Allows GitHub Actions workflows of femiwiki/femiwiki.github.io to read what the site publishes."
  enable_github_oidc = true
  oidc_subjects = [
    "femiwiki@21275875/femiwiki.github.io@1377892969:ref:refs/heads/main",
  ]
}

moved {
  from = aws_iam_role.femiwiki_github_io
  to   = module.femiwiki_github_io.aws_iam_role.this[0]
}

resource "aws_iam_role_policy" "femiwiki_github_io" {
  name   = "FemiwikiGithubIo"
  role   = module.femiwiki_github_io.name
  policy = data.aws_iam_policy_document.femiwiki_github_io.json
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

locals {
  instance_trust = {
    EC2AssumeRole = {
      actions    = ["sts:AssumeRole"]
      principals = [{ type = "Service", identifiers = ["ec2.amazonaws.com"] }]
    }
  }
  instance_managed_policies = {
    for name in ["AmazonSSMManagedInstanceCore", "CloudWatchAgentServerPolicy"] :
    name => "arn:aws:iam::aws:policy/${name}"
  }
}

module "femiwiki" {
  source                   = "terraform-aws-modules/iam/aws//modules/iam-role"
  version                  = "6.8.2"
  name                     = "Femiwiki"
  use_name_prefix          = false
  description              = "Allows EC2 instances to call AWS services on your behalf."
  trust_policy_permissions = local.instance_trust
  policies = merge(local.instance_managed_policies, {
    amazon_s3_access         = aws_iam_policy.amazon_s3_access.arn
    route53                  = aws_iam_policy.route53.arn
    access_caddycerts        = aws_iam_policy.access_caddycerts.arn
    share_rate_limit_state   = aws_iam_policy.share_rate_limit_state.arn
    read_secret_parameters   = aws_iam_policy.read_secret_parameters.arn
    get_google_subject_token = aws_iam_policy.get_google_subject_token.arn
    upload_backup            = aws_iam_policy.upload_backup.arn
    read_alloy_parameters    = aws_iam_policy.read_alloy_parameters.arn
  })
}

module "database" {
  source                   = "terraform-aws-modules/iam/aws//modules/iam-role"
  version                  = "6.8.2"
  name                     = "database"
  use_name_prefix          = false
  description              = "EC2 instance(s) running database"
  trust_policy_permissions = local.instance_trust
  policies = merge(local.instance_managed_policies, {
    upload_backup               = aws_iam_policy.upload_backup.arn
    read_backup                 = aws_iam_policy.read_backup.arn
    read_mysql_user_parameters  = aws_iam_policy.read_mysql_user_parameters.arn
    read_backup_healthcheck_url = aws_iam_policy.read_backup_healthcheck_url.arn
    write_mysql_root_password   = aws_iam_policy.write_mysql_root_password.arn
    read_alloy_parameters       = aws_iam_policy.read_alloy_parameters.arn
  })
}

moved {
  from = aws_iam_role.femiwiki
  to   = module.femiwiki.aws_iam_role.this[0]
}

moved {
  from = aws_iam_role.database
  to   = module.database.aws_iam_role.this[0]
}

moved {
  from = aws_iam_role_policy_attachment.femiwiki_amazon_s3_access
  to   = module.femiwiki.aws_iam_role_policy_attachment.this["amazon_s3_access"]
}

moved {
  from = aws_iam_role_policy_attachment.femiwiki_route53
  to   = module.femiwiki.aws_iam_role_policy_attachment.this["route53"]
}

moved {
  from = aws_iam_role_policy_attachment.femiwiki_access_caddycerts
  to   = module.femiwiki.aws_iam_role_policy_attachment.this["access_caddycerts"]
}

moved {
  from = aws_iam_role_policy_attachment.femiwiki_share_rate_limit_state
  to   = module.femiwiki.aws_iam_role_policy_attachment.this["share_rate_limit_state"]
}

moved {
  from = aws_iam_role_policy_attachment.femiwiki_read_secret_parameters
  to   = module.femiwiki.aws_iam_role_policy_attachment.this["read_secret_parameters"]
}

moved {
  from = aws_iam_role_policy_attachment.femiwiki_get_google_subject_token
  to   = module.femiwiki.aws_iam_role_policy_attachment.this["get_google_subject_token"]
}

moved {
  from = aws_iam_role_policy_attachment.femiwiki_upload_backup
  to   = module.femiwiki.aws_iam_role_policy_attachment.this["upload_backup"]
}

moved {
  from = aws_iam_role_policy_attachment.database_upload_backup
  to   = module.database.aws_iam_role_policy_attachment.this["upload_backup"]
}

moved {
  from = aws_iam_role_policy_attachment.database_read_backup
  to   = module.database.aws_iam_role_policy_attachment.this["read_backup"]
}

moved {
  from = aws_iam_role_policy_attachment.database_read_mysql_user_parameters
  to   = module.database.aws_iam_role_policy_attachment.this["read_mysql_user_parameters"]
}

moved {
  from = aws_iam_role_policy_attachment.database_read_backup_healthcheck_url
  to   = module.database.aws_iam_role_policy_attachment.this["read_backup_healthcheck_url"]
}

moved {
  from = aws_iam_role_policy_attachment.database_write_mysql_root_password
  to   = module.database.aws_iam_role_policy_attachment.this["write_mysql_root_password"]
}

moved {
  from = aws_iam_role_policy_attachment.femiwiki_managed_policies["AmazonSSMManagedInstanceCore"]
  to   = module.femiwiki.aws_iam_role_policy_attachment.this["AmazonSSMManagedInstanceCore"]
}

moved {
  from = aws_iam_role_policy_attachment.femiwiki_managed_policies["CloudWatchAgentServerPolicy"]
  to   = module.femiwiki.aws_iam_role_policy_attachment.this["CloudWatchAgentServerPolicy"]
}

moved {
  from = aws_iam_role_policy_attachment.read_alloy_parameters["femiwiki"]
  to   = module.femiwiki.aws_iam_role_policy_attachment.this["read_alloy_parameters"]
}

moved {
  from = aws_iam_role_policy_attachment.database_managed_policies["AmazonSSMManagedInstanceCore"]
  to   = module.database.aws_iam_role_policy_attachment.this["AmazonSSMManagedInstanceCore"]
}

moved {
  from = aws_iam_role_policy_attachment.database_managed_policies["CloudWatchAgentServerPolicy"]
  to   = module.database.aws_iam_role_policy_attachment.this["CloudWatchAgentServerPolicy"]
}

moved {
  from = aws_iam_role_policy_attachment.read_alloy_parameters["database"]
  to   = module.database.aws_iam_role_policy_attachment.this["read_alloy_parameters"]
}

module "infra_grafana" {
  source             = "terraform-aws-modules/iam/aws//modules/iam-role"
  version            = "6.8.2"
  name               = "infra-grafana"
  use_name_prefix    = false
  description        = "Allows GitHub Actions workflows of femiwiki/infra to keep the grafana workspace's state in S3."
  enable_github_oidc = true
  oidc_subjects = [
    "femiwiki@21275875/infra@188597503:pull_request",
    "femiwiki@21275875/infra@188597503:environment:grafana",
  ]
}

moved {
  from = aws_iam_role.infra_grafana
  to   = module.infra_grafana.aws_iam_role.this[0]
}

resource "aws_iam_role_policy" "infra_grafana" {
  name   = "InfraGrafana"
  role   = module.infra_grafana.name
  policy = data.aws_iam_policy_document.infra_grafana.json
}

module "infra_healthchecks" {
  source             = "terraform-aws-modules/iam/aws//modules/iam-role"
  version            = "6.8.2"
  name               = "infra-healthchecks"
  use_name_prefix    = false
  description        = "Allows GitHub Actions workflows of femiwiki/infra to keep the healthchecks workspace's state in S3."
  enable_github_oidc = true
  oidc_subjects = [
    "femiwiki@21275875/infra@188597503:pull_request",
    "femiwiki@21275875/infra@188597503:environment:healthchecks",
  ]
}

moved {
  from = aws_iam_role.infra_healthchecks
  to   = module.infra_healthchecks.aws_iam_role.this[0]
}

resource "aws_iam_role_policy" "infra_healthchecks" {
  name   = "InfraHealthchecks"
  role   = module.infra_healthchecks.name
  policy = data.aws_iam_policy_document.infra_healthchecks.json
}
