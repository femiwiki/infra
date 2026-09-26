variable "github_token" {
  description = "An installation token for the app that owns this root, minted per run."
  type        = string
  sensitive   = true
}
