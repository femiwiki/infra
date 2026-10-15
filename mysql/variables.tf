variable "mysql_endpoint" {
  description = "host:port of the primary MariaDB, forwarded over SSM"
  type        = string
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
