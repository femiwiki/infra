resource "docker_container" "http" {
  name            = "http-${local.fastcgi_generation}"
  image           = "ghcr.io/femiwiki/femiwiki:2026-09-22T01-02-4b0a06bb"
  command         = ["caddy-run"]
  restart         = "on-failure"
  max_retry_count = 3
  network_mode    = "host"
  memory          = 256

  wait                  = true
  wait_timeout          = 60
  stop_signal           = "SIGTERM"
  destroy_grace_seconds = 30

  lifecycle {
    create_before_destroy = true
  }

  healthcheck {
    test     = ["CMD-SHELL", "curl -sf http://127.0.0.1:$${CADDY_PROBE_PORT}/health-check"]
    interval = "5s"
    timeout  = "3s"
    retries  = 3
  }

  env = [
    for k, v in {
      CADDY_PROBE_PORT    = 8080 + local.fastcgi_generation % 2,
      CADDY_LOG_EXCLUDE   = "http.handlers.mwcache",
      AWS_REGION          = "ap-northeast-1",
      S3_USE_IAM_PROVIDER = "true",
      S3_HOST             = "s3.ap-northeast-1.amazonaws.com",
      S3_BUCKET           = "femiwiki-secrets",
      S3_PREFIX           = "caddycerts",

      BLOCKED_CIDR = join(" ", [
        # Alibaba Cloud LLC
        "47.74.0.0/15", "47.76.0.0/14", "47.80.0.0/13",
        # ColoCrossing
        "104.168.0.0/17",
        "107.172.0.0/14",
        "172.245.0.0/16",
        "192.210.128.0/17",
        "192.227.128.0/17",
        "192.3.0.0/16",
        "198.144.176.0/20",
        "198.46.128.0/17",
        "23.94.0.0/15",
      ]),
    } : "${k}=${v}"
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

  labels {
    label = "autoheal"
    value = "false"
  }
}

resource "docker_container" "fastcgi" {
  name         = "fastcgi-${local.fastcgi_generation}"
  image        = "ghcr.io/femiwiki/femiwiki:2026-09-22T01-02-4b0a06bb"
  network_mode = "host"
  restart      = "always"
  memory       = 768

  wait                  = true
  wait_timeout          = 300
  stop_signal           = "SIGTERM"
  destroy_grace_seconds = 45

  lifecycle {
    create_before_destroy = true
  }

  env = [
    for k, v in {
      PHP_FPM_LISTEN = 9000 + local.fastcgi_generation % 2

      PHP_FPM_EMERGENCY_RESTART_THRESHOLD = "5"
      PHP_FPM_EMERGENCY_RESTART_INTERVAL  = "1m"
      PHP_FPM_PROCESS_CONTROL_TIMEOUT     = "10s"
      PHP_FPM_REQUEST_TERMINATE_TIMEOUT   = "30"

      PHP_FPM_PM_MAX_CHILDREN      = "10"
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
      FCGI_URL = "127.0.0.1:${9000 + local.fastcgi_generation % 2}"

      WG_DB_SERVER           = "${data.aws_instances.database.private_ips[0]}:3306"
      WG_DB_USER             = "mediawiki"
      WG_RE_CAPTCHA_SITE_KEY = "6LfiSLArAAAAAKFLIhAJC2wlNY1Nnbm_gNcXRIDh"

      SSM_SECRETS = "1"
      AWS_REGION  = "ap-northeast-1"
    } : "${k}=${v}"
  ]

  healthcheck {
    test     = ["CMD-SHELL", "/usr/local/bin/php /srv/fcgi-check/fcgi-probe.php || exit 1"]
    interval = "30s"
    timeout  = "5s"
    retries  = 3
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
  memory       = 128

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
  memory       = 64

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
  image   = "ghcr.io/femiwiki/backupbot:2026-09-22T12-21-55d00ae7"
  restart = "always"
  memory  = 256
  env = [
    for k, v in {
      DB_SERVER   = "${data.aws_instances.database.private_ips[0]}:3306"
      SSM_SECRETS = "1"
      AWS_REGION  = "ap-northeast-1"
    } : "${k}=${v}"
  ]

  healthcheck {
    test = ["NONE"]
  }

  ulimit {
    hard = 65536
    name = "nofile"
    soft = 32768
  }

  labels {
    label = "autoheal"
    value = "false"
  }
}
