# Passwords stay with whatever set them: setting one here runs ALTER USER.
resource "mysql_user" "mediawiki" {
  user = "mediawiki"
  host = "%"
}

resource "mysql_grant" "mediawiki_global" {
  user       = mysql_user.mediawiki.user
  host       = mysql_user.mediawiki.host
  database   = "*"
  privileges = ["RELOAD", "PROCESS"]
}

resource "mysql_grant" "mediawiki_femiwiki" {
  user       = mysql_user.mediawiki.user
  host       = mysql_user.mediawiki.host
  database   = "femiwiki"
  privileges = ["ALL PRIVILEGES"]
}

resource "mysql_user" "backup" {
  user = "backup"
  host = "localhost"
}

resource "mysql_grant" "backup_global" {
  user       = mysql_user.backup.user
  host       = mysql_user.backup.host
  database   = "*"
  privileges = ["RELOAD", "PROCESS"]
}

resource "mysql_grant" "backup_femiwiki" {
  user       = mysql_user.backup.user
  host       = mysql_user.backup.host
  database   = "femiwiki"
  privileges = ["SELECT", "SHOW VIEW", "TRIGGER"]
}

import {
  to = mysql_user.mediawiki
  id = "mediawiki@%"
}

import {
  to = mysql_grant.mediawiki_global
  id = "mediawiki@%@*@*"
}

import {
  to = mysql_grant.mediawiki_femiwiki
  id = "mediawiki@%@femiwiki@*"
}

import {
  to = mysql_user.backup
  id = "backup@localhost"
}

import {
  to = mysql_grant.backup_global
  id = "backup@localhost@*@*"
}

import {
  to = mysql_grant.backup_femiwiki
  id = "backup@localhost@femiwiki@*"
}
