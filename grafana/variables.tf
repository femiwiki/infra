variable "grafana_auth" {
  description = "Service account token with alerting provisioning rights"
  type        = string
  sensitive   = true
}

variable "discord_webhook_url" {
  description = "Webhook the site-down contact point posts to"
  type        = string
  sensitive   = true
}

variable "discord_mention_role_id" {
  description = "Discord role the site-down notification mentions"
  type        = string
  default     = "678974055365476392"
}
