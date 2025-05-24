variable "db_user_password" {
  type      = string
  sensitive = true
}

variable "prometheus_password" {
  type      = string
  sensitive = true
}

variable "loki_password" {
  type      = string
  sensitive = true
}
