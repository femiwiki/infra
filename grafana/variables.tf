variable "grafana_auth" {
  description = "Service account token with alerting provisioning rights"
  type        = string
  sensitive   = true
  # The plan job reads with one token and the apply job writes with another,
  # so the saved plan the apply job runs must not hold it
  ephemeral = true
}

variable "grafana_cloud_auth" {
  description = "Cloud access policy token that reads stacks and manages access policies"
  type        = string
  sensitive   = true
  # Read-only in the plan job, read-write in the apply job, like grafana_auth
  ephemeral = true
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

variable "state_passphrase" {
  description = "Passphrase of this state"
  type        = string
  sensitive   = true
}

variable "aws_state_passphrase" {
  description = "Passphrase of the aws state, read for its outputs"
  type        = string
  sensitive   = true
}
