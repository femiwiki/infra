variable "github_token" {
  description = "An installation token for the app that owns this root, minted per run."
  type        = string
  sensitive   = true
}

variable "state_passphrase" {
  description = "Encrypts the state and plan files. Losing it loses the state."
  type        = string
  sensitive   = true
}
