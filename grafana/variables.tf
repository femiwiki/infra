variable "grafana_auth" {
  description = "Service account token with alerting provisioning rights"
  type        = string
  sensitive   = true
}
