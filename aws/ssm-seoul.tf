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
