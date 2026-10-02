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

import {
  for_each = local.secret_parameters

  to = aws_ssm_parameter.secret_seoul[each.key]
  id = "${each.key}@${local.seoul_region}"
}

resource "aws_ssm_parameter" "secret_seoul" {
  for_each = local.secret_parameters

  region = local.seoul_region
  name   = each.key
  type   = "String"
  value  = "placeholder"

  lifecycle {
    ignore_changes = [value]
  }
}
