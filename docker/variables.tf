variable "docker_host" {
  type    = string
  default = "tcp://127.0.0.1:2376"
  # Each job forwards its own port, so the saved plan the apply job runs must
  # not hold it
  ephemeral = true
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

variable "gcp_state_passphrase" {
  description = "Passphrase of the gcp state, read for its outputs"
  type        = string
  sensitive   = true
}

variable "proxysql_enabled" {
  description = "Whether the wiki reaches the database through ProxySQL, as the database replacement workflow has it during a swap"
  type        = bool
  default     = false
}
