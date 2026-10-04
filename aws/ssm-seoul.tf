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

# Written by hand, so the values stay out of the configuration; only the type is
# managed here (femiwiki/femiwiki#597).
locals {
  secret_parameters = toset([
    "/mediawiki/o_auth_2_private_key",
    "/mediawiki/rc_feeds_discord_url",
    "/mediawiki/re_captcha/secret_key",
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
