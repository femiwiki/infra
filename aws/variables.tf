variable "prometheus_password" {
  type      = string
  sensitive = true
}

variable "loki_password" {
  type      = string
  sensitive = true
}

variable "internet_archive_access_key" {
  type      = string
  sensitive = true
}

variable "internet_archive_secret_key" {
  type      = string
  sensitive = true
}

variable "h_captcha_secret_key" {
  type      = string
  sensitive = true
}

variable "state_passphrase" {
  description = "Encrypts the state and plan files. Losing it loses the state."
  type        = string
  sensitive   = true
}
