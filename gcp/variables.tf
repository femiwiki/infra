variable "state_passphrase" {
  description = "Encrypts the state and plan files. Losing it loses the state."
  type        = string
  sensitive   = true
}

variable "aws_state_passphrase" {
  description = "Decrypts the aws state, to read its outputs"
  type        = string
  sensitive   = true
}
