resource "docker_container" "http" {
  name            = "http"
  image           = "ghcr.io/femiwiki/femiwiki:2025-09-03T12-42-95d3b463"
  command         = ["caddy", "run"]
  restart         = "on-failure"
  max_retry_count = 3
  network_mode    = "host"

  env = [
    "FASTCGI_ADDR=127.0.0.1:9000",
    "AWS_REGION=ap-northeast-1",
    "S3_USE_IAM_PROVIDER=true",
    "S3_HOST=s3.ap-northeast-1.amazonaws.com",
    "S3_BUCKET=femiwiki-secrets",
    "S3_PREFIX=caddycerts",
  ]

  mounts {
    type      = "volume"
    source    = docker_volume.sitemap.id
    target    = "/srv/femiwiki.com/sitemap"
    read_only = true
  }

  ulimit {
    hard = 65536
    name = "nofile"
    soft = 32768
  }
}

resource "docker_container" "fastcgi" {
  name         = "fastcgi"
  image        = "ghcr.io/femiwiki/femiwiki:2025-09-03T12-42-95d3b463"
  network_mode = "host"
  restart      = "always"
  env = [
    for k, v in {
      PHP_FPM_EMERGENCY_RESTART_THRESHOLD = "5"
      PHP_FPM_EMERGENCY_RESTART_INTERVAL  = "1m"
      PHP_FPM_PROCESS_CONTROL_TIMEOUT     = "10s"
      PHP_FPM_REQUEST_TERMINATE_TIMEOUT   = "30"

      PHP_FPM_PM_MAX_CHILDREN      = "100"
      PHP_FPM_PM_START_SERVERS     = "2"
      PHP_FPM_PM_MIN_SPARE_SERVERS = "1"
      PHP_FPM_PM_MAX_SPARE_SERVERS = "3"
      PHP_FPM_PM_MAX_REQUESTS      = "200"

      PHP_POST_MAX_SIZE       = "10M"
      PHP_UPLOAD_MAX_FILESIZE = "10M"

      MEDIAWIKI_SKIP_IMPORT_SITES = "1"
      MEDIAWIKI_SKIP_INSTALL      = "1"
      MEDIAWIKI_SKIP_UPDATE       = "1"
      MEDIAWIKI_HOTFIX_SNIPPET    = file("res/Hotfix.php")

      WG_BOUNCE_HANDLER_INTERNAL_IPS = "172.31.0.0/16"
      WG_CDN_SERVERS                 = "127.0.0.1:80"
      WG_INTERNAL_SERVER             = "http://127.0.0.1:80"
      WG_MEMCACHED_SERVERS           = "127.0.0.1:11211"
      # Used by fcgi-probe.php
      FCGI_URL = "127.0.0.1:9000"

      WG_DB_SERVER             = "${data.terraform_remote_state.aws.outputs.mysql_private_ip}:3306"
      WG_DB_USER               = local.ssm_parameters_mysql["/mysql/users/mediawiki/username"]
      WG_DB_PASSWORD           = local.ssm_parameters_mysql["/mysql/users/mediawiki/password"]
      WG_O_AUTH_2_PRIVATE_KEY  = local.ssm_parameters_mediawiki["/mediawiki/o_auth_2_private_key"]
      WG_RC_FEEDS_DISCORD_URL  = local.ssm_parameters_mediawiki["/mediawiki/rc_feeds_discord_url"]
      WG_RE_CAPTCHA_SECRET_KEY = local.ssm_parameters_mediawiki["/mediawiki/re_captcha/secret_key"]
      WG_RE_CAPTCHA_SITE_KEY   = local.ssm_parameters_mediawiki["/mediawiki/re_captcha/site_key"]
      WG_SECRET_KEY            = local.ssm_parameters_mediawiki["/mediawiki/site_key"]
      WG_SMTP_PASSWORD         = local.ssm_parameters_mediawiki["/mediawiki/smtp/password"]
      WG_SMTP_USERNAME         = local.ssm_parameters_mediawiki["/mediawiki/smtp/username"]
      WG_UPGRADE_KEY           = local.ssm_parameters_mediawiki["/mediawiki/upgrade_key"]
    } : "${k}=${v}"
  ]

  healthcheck {
    test = ["CMD-SHELL", <<-EOF
      if [ ! -d /srv/fcgi-check ]; then
        mkdir -p /srv/fcgi-check/
      fi &&
      if [ ! -z /srv/fcgi-check/AdoyFastCgiClient.php ]; then
        curl -L https://github.com/wikimedia/operations-docker-images-production-images/raw/ad68c7cb62e4e01436ab3a34fb961fe8034c2cce/images/php/common/fpm/live-test/AdoyFastCgiClient.php -o /srv/fcgi-check/AdoyFastCgiClient.php
      fi &&
      if [ ! -z /srv/fcgi-check/fcgi-probe.php ]; then
        curl -L https://github.com/wikimedia/operations-docker-images-production-images/raw/ad68c7cb62e4e01436ab3a34fb961fe8034c2cce/images/php/common/fpm/live-test/fcgi-probe.php -o /srv/fcgi-check/fcgi-probe.php
      fi &&
      /usr/local/bin/php /srv/fcgi-check/fcgi-probe.php || exit 1
      EOF
    ]
    interval = "5s"
    timeout  = "1s"
    retries  = 0
  }

  mounts {
    type      = "volume"
    source    = docker_volume.sitemap.id
    target    = "/srv/femiwiki.com/sitemap"
    read_only = false
  }

  mounts {
    type      = "volume"
    target    = "/tmp/cache"
    read_only = false
  }

  ulimit {
    hard = 65536
    name = "nofile"
    soft = 32768
  }

  labels {
    label = "autoheal"
    value = "true"
  }
}

resource "docker_container" "memcached" {
  name         = "memcached"
  image        = "memcached:1.6.23-alpine"
  network_mode = "host"
  restart      = "always"

  labels {
    label = "autoheal"
    value = "true"
  }

  ulimit {
    hard = 65536
    name = "nofile"
    soft = 32768
  }
}

resource "docker_container" "autoheal" {
  name         = "autoheal"
  image        = "willfarrell/autoheal:1.1.0"
  network_mode = "none"
  restart      = "always"
  env          = ["AUTOHEAL_CONTAINER_LABEL=autoheal"]

  mounts {
    type      = "bind"
    source    = "/etc/localtime"
    target    = "/etc/localtime"
    read_only = true
  }

  mounts {
    type      = "bind"
    source    = "/var/run/docker.sock"
    target    = "/var/run/docker.sock"
    read_only = false
  }

  ulimit {
    hard = 65536
    name = "nofile"
    soft = 32768
  }
}

resource "docker_container" "backupbot" {
  name    = "backupbot"
  image   = "ghcr.io/femiwiki/backupbot:2025-08-31T08-55-d756cc34"
  restart = "always"
  env = [
    for k, v in {
      DB_SERVER   = "${data.terraform_remote_state.aws.outputs.mysql_private_ip}:3306"
      DB_USERNAME = local.ssm_parameters_mysql["/mysql/users/mediawiki/username"]
      DB_PASSWORD = local.ssm_parameters_mysql["/mysql/users/mediawiki/password"]
    } : "${k}=${v}"
  ]

  ulimit {
    hard = 65536
    name = "nofile"
    soft = 32768
  }
}
