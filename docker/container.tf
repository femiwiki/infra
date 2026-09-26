resource "docker_container" "http" {
  name         = "http-${local.fastcgi_generation}"
  log_driver   = "local"
  image        = "ghcr.io/femiwiki/femiwiki:2026-09-26T00-18-46177254"
  command      = ["caddy-run"]
  restart      = "always"
  network_mode = "host"
  memory       = 384
  memory_swap  = 768

  wait                  = true
  wait_timeout          = 60
  stop_signal           = "SIGTERM"
  destroy_grace_seconds = 30

  lifecycle {
    create_before_destroy = true
  }

  healthcheck {
    test         = ["CMD-SHELL", "curl -sf http://127.0.0.1:$${FW_PROBE_PORT}/health-check"]
    interval     = "5s"
    timeout      = "3s"
    retries      = 7
    start_period = "1m0s"
  }

  env = [
    for k, v in {
      FW_PROBE_PORT   = 8080 + local.fastcgi_generation % 2,
      FW_METRICS_PORT = 9180 + local.fastcgi_generation % 2,

      PHP_FPM_LISTEN        = 9000 + local.fastcgi_generation % 2,
      PHP_FPM_STATUS_LISTEN = 9200 + local.fastcgi_generation % 2,

      FW_CRAWLER_AGENTS = "(?i)(bot|spider|crawl|Claude-Web|meta-external)",

      # Exempts loopback and Chrome on iOS from the image's default; see femiwiki#523
      FW_BOTLIKE             = "!remote_ip('127.0.0.0/8') && ((header_regexp('User-Agent', '(Chrome|Chromium|Edg|CriOS)/') && ((!header_regexp('Sec-Ch-Ua', '.') && !header_regexp('User-Agent', 'CriOS/')) || !header_regexp('Priority', '.') || header_regexp('Accept-Language', 'q=0\\\\.5'))) || !header_regexp('User-Agent', '(Mozilla/5\\\\.0|Opera)'))"
      FW_CRAWLER_EVENTS      = "10",
      FW_CRAWLER_LEAN_EVENTS = "3",
      FW_EXPENSIVE_EVENTS    = "60",
      FW_EXPENSIVE_IP_EVENTS = "15",

      FW_LOG_EXCLUDE      = "http.handlers.mwcache",
      FW_CADDYFILE        = file("res/Caddyfile"),
      FW_ROBOTS_TXT       = file("res/robots.txt"),
      AWS_REGION          = "ap-northeast-1",
      S3_USE_IAM_PROVIDER = "true",
      S3_HOST             = "s3.ap-northeast-1.amazonaws.com",
      S3_BUCKET           = "femiwiki-secrets",
      S3_PREFIX           = "caddycerts",

      BLOCKED_CIDR = join(" ", [
        # Alibaba Cloud LLC
        "47.74.0.0/15", "47.76.0.0/14", "47.80.0.0/13",
        # ACEVILLE PTE.LTD and TencentCloud, as APNIC registers them
        "43.128.64.0/18", "43.153.0.0/17", "43.154.0.0/16", "43.156.0.0/16",
        "43.157.0.0/17", "43.160.0.0/12",
        "49.51.0.0/16", "119.28.0.0/15", "124.156.96.0/19", "124.156.128.0/18",
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
    value = "true"
  }
}

resource "docker_container" "fastcgi" {
  name         = "fastcgi-${local.fastcgi_generation}"
  log_driver   = "local"
  image        = "ghcr.io/femiwiki/femiwiki:2026-09-26T00-18-46177254"
  network_mode = "host"
  restart      = "always"
  memory       = 768
  memory_swap  = 1536

  wait                  = true
  wait_timeout          = 600
  stop_signal           = "SIGTERM"
  destroy_grace_seconds = 45

  lifecycle {
    create_before_destroy = true
  }

  env = [
    for k, v in {
      PHP_FPM_LISTEN       = 9000 + local.fastcgi_generation % 2
      PHP_FPM_PROBE_LISTEN = 9100 + local.fastcgi_generation % 2

      PHP_FPM_EMERGENCY_RESTART_THRESHOLD = "5"
      PHP_FPM_EMERGENCY_RESTART_INTERVAL  = "1m"
      PHP_FPM_PROCESS_CONTROL_TIMEOUT     = "10s"
      PHP_FPM_REQUEST_TERMINATE_TIMEOUT   = "30"

      PHP_OPCACHE_MEMORY_CONSUMPTION = "192"
      # 4000 rounded up to 7963 key slots and 5,170 scripts filled them; 10000 is
      # PHP's next size, 16229. Memory was never the ceiling. See femiwiki#587.
      PHP_OPCACHE_MAX_ACCELERATED_FILES   = "10000"
      PHP_OPCACHE_INTERNED_STRINGS_BUFFER = "48"

      PHP_FPM_PM_MAX_CHILDREN      = "16"
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

      FW_PROFILER = "excimer"
      # Every request is instrumented, so nothing slow can be missed, but only
      # the ones past the threshold are written. Excimer samples on a timer, so
      # the cost is the sampling rate and not the number of requests.
      FW_PROFILER_SAMPLING = "1"
      # action=flow takes 5 to 9 seconds (femiwiki#576); a normal page is under
      # one, so 3 keeps the ordinary traffic out of the directory
      FW_PROFILER_THRESHOLD = "3"

      WG_BOUNCE_HANDLER_INTERNAL_IPS = "172.31.0.0/16"
      WG_CDN_SERVERS                 = "127.0.0.1:80"
      WG_INTERNAL_SERVER             = "http://127.0.0.1:80"
      WG_MEMCACHED_SERVERS           = "127.0.0.1:11211"
      # Used by fcgi-probe.php
      FCGI_URL = "127.0.0.1:${9100 + local.fastcgi_generation % 2}"

      WG_DB_SERVER           = "${data.aws_instances.database.private_ips[0]}:3306"
      WG_DB_USER             = "mediawiki"
      WG_RE_CAPTCHA_SITE_KEY = "6LfiSLArAAAAAKFLIhAJC2wlNY1Nnbm_gNcXRIDh"

      SSM_SECRETS = "1"
      AWS_REGION  = "ap-northeast-1"
    } : "${k}=${v}"
  ]

  healthcheck {
    test         = ["CMD-SHELL", "test ! -e /tmp/warming && /usr/local/bin/php /srv/fcgi-check/fcgi-probe.php"]
    interval     = "10s"
    timeout      = "10s"
    retries      = 3
    start_period = "4m0s"
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
  log_driver   = "local"
  image        = "memcached:1.6.23-alpine"
  command      = ["memcached", "-m", tostring(local.memcached_item_mib)]
  network_mode = "host"
  restart      = "always"
  memory       = local.memcached_mib
  memory_swap  = local.memcached_mib

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
  log_driver   = "local"
  image        = "willfarrell/autoheal:1.1.0"
  network_mode = "none"
  restart      = "always"
  memory       = 64
  memory_swap  = 64
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
  name        = "backupbot"
  image       = "ghcr.io/femiwiki/backupbot:2026-09-22T15-01-939d63be"
  restart     = "always"
  init        = true
  log_driver  = "local"
  memory      = 256
  memory_swap = 256
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
