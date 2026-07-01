#
# Alloy (Grafana Cloud) credentials for the ASG nodes.
#
# The EDGE bakes these into user-data from var.prometheus_password / var.loki_password
# at plan time (ec2.tf:74). ASG user-data is re-rendered on every instance refresh and
# is readable by anything on the box, so the backend fetches the creds from SSM at boot
# instead of baking them. The non-secret Alloy fields (endpoints, usernames) stay
# templated in res/config.alloy.tftpl; only the two passwords come from here.
#
resource "aws_ssm_parameter" "alloy_prometheus_password" {
  name        = "/alloy/prometheus_password"
  description = "Grafana Cloud Prometheus remote_write password (ASG nodes)"
  type        = "SecureString"
  value       = var.prometheus_password
}

resource "aws_ssm_parameter" "alloy_loki_password" {
  name        = "/alloy/loki_password"
  description = "Grafana Cloud Loki push password (ASG nodes)"
  type        = "SecureString"
  value       = var.loki_password
}
