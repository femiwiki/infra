data "healthchecksio_channel" "discord" {
  kind = "discord"
}

resource "healthchecksio_check" "mysql_backup" {
  name = "mysql-backup"
  desc = "The database host pings this after each day's dump of the wiki database reaches S3, from its mysql-backup systemd timer."

  schedule = "0 6 * * *"
  timezone = "Asia/Seoul"
  grace    = 2 * 60 * 60

  channels = [data.healthchecksio_channel.discord.id]
}
