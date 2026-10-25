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

variable "mysql_password" {
  description = "Password of mysql_username, which the job reads from Parameter Store with its own role"
  type        = string
  sensitive   = true
  ephemeral   = true
}

variable "repl_password" {
  description = "Password of the replication account"
  type        = string
  sensitive   = true
  ephemeral   = true
}
