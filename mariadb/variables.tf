variable "mariadb_endpoint" {
  description = "host:port of the primary MariaDB, forwarded over SSM"
  type        = string
  # Each job forwards its own port, so the saved plan the apply job runs must
  # not hold it
  ephemeral = true
}

variable "state_passphrase" {
  description = "Passphrase of this state"
  type        = string
  sensitive   = true
}

variable "mysql_username" {
  description = "The MariaDB account to log in as: tofu-plan for plans of pull requests, tofu for applies"
  type        = string
  ephemeral   = true
}
