variable "grafana_auth" {
  description = "Service account token with alerting provisioning rights"
  type        = string
  sensitive   = true
}

variable "discord_webhook_url" {
  description = "Webhook the Discord contact points post to"
  type        = string
  sensitive   = true
}

variable "discord_mention_role_id" {
  description = "Discord role the notifications mention"
  type        = string
  default     = "678974055365476392"
}

variable "mastodon_token" {
  description = "Access token for @femiwiki_status on mastodon.social, scope write:statuses"
  type        = string
  sensitive   = true
}

variable "alerts_webhook_token" {
  description = "Bearer token the grafana-github Lambda function expects"
  type        = string
  sensitive   = true
}
