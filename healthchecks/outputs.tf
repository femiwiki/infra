# The URL is only known where the check is made, and backupbot looks it up in
# SSM, which the aws workspace writes. That workspace reads this out of the
# state file.
output "mysql_backup_ping_url" {
  value     = healthchecksio_check.mysql_backup.ping_url
  sensitive = true
}
