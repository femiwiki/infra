data "aws_ssm_parameters_by_path" "mysql" {
  path      = "/mysql/"
  recursive = true
}

data "aws_ssm_parameters_by_path" "mediawiki" {
  path      = "/mediawiki/"
  recursive = true
}

# The check lives in the healthchecks workspace and its ping URL is only known
# there, so it comes across the way Terraform Cloud hands one workspace's
# outputs to another. backupbot reads the parameter when its container starts.
data "terraform_remote_state" "healthchecks" {
  backend = "s3"

  config = {
    bucket = aws_s3_bucket.tfstate.bucket
    key    = "healthchecks/terraform.tfstate"
    region = data.aws_region.current.region
  }
}

resource "aws_ssm_parameter" "mysql_backup_healthcheck_url" {
  name  = "/mysql/backup/healthcheck-url"
  type  = "SecureString"
  value = data.terraform_remote_state.healthchecks.outputs.mysql_backup_ping_url
}
