resource "aws_ssm_parameter" "alloy_seoul" {
  for_each = {
    loki_password       = var.loki_password
    prometheus_password = var.prometheus_password
  }

  region = local.seoul_region
  name   = "/alloy/${each.key}"
  type   = "SecureString"
  value  = each.value
}

# Read by publish-dump in the MediaWiki image (femiwiki/docker-mediawiki#1235).
resource "aws_ssm_parameter" "internet_archive" {
  for_each = {
    access_key = var.internet_archive_access_key
    secret_key = var.internet_archive_secret_key
  }

  region = local.seoul_region
  name   = "/mediawiki/internet_archive/${each.key}"
  type   = "SecureString"
  value  = each.value
}

# Read by the MediaWiki image's ConfirmEdit (femiwiki/femiwiki#668).
resource "aws_ssm_parameter" "h_captcha_secret_key" {
  region = local.seoul_region
  name   = "/mediawiki/h_captcha/secret_key"
  type   = "SecureString"
  value  = var.h_captcha_secret_key
}

# Read by the MediaWiki image to send slow-request profiles; the profiles:write
# token is made by grafana/access-policies.tf (femiwiki/femiwiki#614).
resource "aws_ssm_parameter" "pyroscope_password" {
  region = local.seoul_region
  name   = "/mediawiki/pyroscope/password"
  type   = "SecureString"
  value  = var.pyroscope_password
}

moved {
  from = aws_ssm_parameter.secret_seoul["/mediawiki/pyroscope/password"]
  to   = aws_ssm_parameter.pyroscope_password
}

# Written by hand, so the values stay out of the configuration; only the type is
# managed here (femiwiki/femiwiki#597).
locals {
  secret_parameters = toset([
    "/mediawiki/bounce_handler/token",
    "/mediawiki/o_auth_2_private_key",
    "/mediawiki/rc_feeds_discord_url",
    "/mediawiki/site_key",
    "/mediawiki/smtp/password",
    "/mediawiki/verp_secret",
    "/mysql/users/mediawiki/password",
  ])
}

resource "aws_ssm_parameter" "secret_seoul" {
  for_each = local.secret_parameters

  region = local.seoul_region
  name   = each.key
  type   = "SecureString"
  value  = "placeholder"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "random_password" "mysql_tofu" {
  length  = 32
  special = false
}

# Read by the mariadb workspace to log in, and by a new database host to create
# the account.
resource "aws_ssm_parameter" "mysql_tofu_password" {
  region = local.seoul_region
  name   = "/mysql/users/tofu/password"
  type   = "SecureString"
  value  = random_password.mysql_tofu.result
}

resource "random_password" "mysql_tofu_plan" {
  length  = 32
  special = false
}

# Read by mariadb plans of pull requests to log in, and by a new database host
# to create the account.
resource "aws_ssm_parameter" "mysql_tofu_plan_password" {
  region = local.seoul_region
  name   = "/mysql/users/tofu-plan/password"
  type   = "SecureString"
  value  = random_password.mysql_tofu_plan.result
}

resource "random_password" "mariadb_repl" {
  length  = 32
  special = false
}

# For the mariadb workspace and for a new host that replicates the primary.
resource "aws_ssm_parameter" "mariadb_repl_password" {
  region = local.seoul_region
  name   = "/mariadb/users/repl/password"
  type   = "SecureString"
  value  = random_password.mariadb_repl.result
}

# The next database host's server_id, raised by the replacement workflow so no
# id comes back: a replica skips events that carry its own id.
resource "aws_ssm_parameter" "mariadb_next_server_id" {
  region = local.seoul_region
  name   = "/mariadb/server-id/next"
  type   = "String"
  value  = "6"

  lifecycle {
    ignore_changes = [value]
  }
}
