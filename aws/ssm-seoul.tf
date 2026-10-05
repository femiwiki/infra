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

# Read by PageViewInfoGA in the MediaWiki image (femiwiki/docker-mediawiki#1282).
resource "aws_ssm_parameter" "google_analytics_credentials" {
  region = local.seoul_region
  name   = "/mediawiki/google_analytics/credentials"
  type   = "SecureString"
  value  = data.terraform_remote_state.gcp.outputs.pageviewinfoga_credentials
}

moved {
  from = aws_ssm_parameter.secret_seoul["/mediawiki/google_analytics/credentials"]
  to   = aws_ssm_parameter.google_analytics_credentials
}

# Written by hand, so the values stay out of the configuration; only the type is
# managed here (femiwiki/femiwiki#597).
locals {
  secret_parameters = toset([
    "/mediawiki/o_auth_2_private_key",
    "/mediawiki/rc_feeds_discord_url",
    "/mediawiki/site_key",
    "/mediawiki/smtp/password",
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
