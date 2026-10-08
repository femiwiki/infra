resource "docker_container" "http" {
  name         = "http-${local.fastcgi_generation}"
  log_driver   = "local"
  image        = "ghcr.io/femiwiki/femiwiki:2026-10-08T22-20-f17ab8b7"
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
      FW_DYNAMIC_EVENTS      = "120",
      FW_EXPENSIVE_EVENTS    = "60",
      FW_EXPENSIVE_IP_EVENTS = "15",

      FW_LOG_EXCLUDE      = "http.handlers.mwcache",
      FW_CADDYFILE        = file("../serving/Caddyfile"),
      FW_ROBOTS_TXT       = file("../serving/robots.txt"),
      FW_DEAD_URLS        = join("\n", [for l in split("\n", file("../serving/dead-urls.txt")) : l if trimspace(l) != "" && !startswith(l, "#")]),
      AWS_REGION          = "ap-northeast-2",
      S3_USE_IAM_PROVIDER = "true",
      S3_HOST             = data.terraform_remote_state.aws.outputs.caddy_certs_s3_host,
      S3_BUCKET           = data.terraform_remote_state.aws.outputs.caddy_certs_bucket,
      S3_PREFIX           = "caddycerts",

      FW_RATE_LIMIT_S3_HOST   = data.terraform_remote_state.aws.outputs.rate_limit_s3_host,
      FW_RATE_LIMIT_S3_BUCKET = data.terraform_remote_state.aws.outputs.rate_limit_bucket,

      # CloudFront's origin-facing ranges, for trusted_proxies. When AWS changes them:
      # curl -s https://ip-ranges.amazonaws.com/ip-ranges.json | jq -r '.prefixes[] | select(.service == "CLOUDFRONT_ORIGIN_FACING") | .ip_prefix' | sort -uV
      FW_TRUSTED_PROXIES = join(" ", split("\n", trimspace(file("../serving/cloudfront-origin-facing.txt")))),

      # Route 53's health checker ranges, let through the special_pages zone. When AWS changes them:
      # curl -s https://ip-ranges.amazonaws.com/ip-ranges.json | jq -r '(.prefixes[] | select(.service == "ROUTE53_HEALTHCHECKS") | .ip_prefix), (.ipv6_prefixes[] | select(.service == "ROUTE53_HEALTHCHECKS") | .ipv6_prefix)' | sort -uV
      FW_ROUTE53_HEALTHCHECKS = join(" ", split("\n", trimspace(file("../serving/route53-healthchecks.txt")))),
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
  image        = "ghcr.io/femiwiki/femiwiki:2026-10-08T22-20-f17ab8b7"
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

      # Includes the interned buffer below. Each language the l10n cache loads
      # adds about 0.9 MB of script and 2 MB of strings; see docker-mediawiki#1294.
      PHP_OPCACHE_MEMORY_CONSUMPTION = "320"
      # 4000 rounded up to 7963 key slots and 5,170 scripts filled them; 10000 is
      # PHP's next size, 16229. Memory was never the ceiling. See femiwiki#587.
      PHP_OPCACHE_MAX_ACCELERATED_FILES   = "10000"
      PHP_OPCACHE_INTERNED_STRINGS_BUFFER = "96"

      PHP_FPM_PM_MAX_CHILDREN      = "16"
      PHP_FPM_PM_START_SERVERS     = "16" # max_children, so a new generation takes over at full size
      PHP_FPM_PM_MIN_SPARE_SERVERS = "8"  # php-fpm forks min_spare - idle a second at most; 1 meant one child a second
      PHP_FPM_PM_MAX_SPARE_SERVERS = "16" # max_children, so the start servers are not reaped before the swap
      PHP_FPM_PM_MAX_REQUESTS      = "200"

      PHP_POST_MAX_SIZE       = "10M"
      PHP_UPLOAD_MAX_FILESIZE = "10M"

      MEDIAWIKI_SKIP_IMPORT_SITES = "1"
      MEDIAWIKI_SKIP_INSTALL      = "1"
      MEDIAWIKI_SKIP_UPDATE       = "1"
      MEDIAWIKI_HOTFIX_SNIPPET    = file("../serving/Hotfix.php")

      FW_PROFILER = "excimer"
      # Every request is instrumented, so nothing slow can be missed, but only
      # the ones past the threshold are written. Excimer samples on a timer, so
      # the cost is the sampling rate and not the number of requests.
      FW_PROFILER_SAMPLING = "1"
      # action=flow takes 5 to 9 seconds (femiwiki#576); a normal page is under
      # one, so 3 keeps the ordinary traffic out of the directory
      FW_PROFILER_THRESHOLD = "3"

      WG_BOUNCE_HANDLER_INTERNAL_IPS = "10.20.0.0/16"
      WG_CDN_SERVERS                 = "127.0.0.1:80"
      WG_INTERNAL_SERVER             = "http://127.0.0.1:80"
      WG_MEMCACHED_SERVERS           = "127.0.0.1:11211"
      # The C client. The pure-PHP one spends about 14% of a page's CPU on its
      # sockets (#1073); the pecl keys start cold under pecl/ (#1134)
      FW_MAIN_CACHE    = "memcached-pecl"
      FW_PARSER_CACHE  = "memcached-pecl"
      FW_MESSAGE_CACHE = "memcached-pecl"
      # Used by fcgi-probe.php and databasez-probe.php
      FCGI_URL = "127.0.0.1:${9100 + local.fastcgi_generation % 2}"

      WG_DB_SERVER          = "${data.aws_instances.database.private_ips[0]}:3306"
      WG_DB_USER            = "mediawiki"
      WG_SESSION_DB_NAME    = "femiwiki_sessions"
      WG_H_CAPTCHA_SITE_KEY = "6cb24780-3282-490c-9b4e-83122cb04cda"

      SSM_SECRETS = "1"
      AWS_REGION  = "ap-northeast-2"
    } : "${k}=${v}"
  ]

  healthcheck {
    test         = ["CMD-SHELL", "test ! -e /tmp/warming && /usr/local/bin/php /srv/fcgi-check/fcgi-probe.php && /usr/local/bin/php /srv/fcgi-check/databasez-probe.php"]
    interval     = "10s"
    timeout      = "10s"
    retries      = 3
    start_period = "4m0s"
  }

  upload {
    file    = "/usr/local/etc/php-fpm.d/zzz-backlog.conf"
    content = "[www]\nlisten.backlog = 64\n"
  }

  upload {
    file = "/etc/mediawiki/google-analytics.json"
    content = jsonencode({
      universe_domain    = "googleapis.com"
      type               = "external_account"
      audience           = data.terraform_remote_state.gcp.outputs.pageviewinfoga_audience
      subject_token_type = "urn:ietf:params:oauth:token-type:jwt"
      token_url          = "https://sts.googleapis.com/v1/token"
      credential_source = {
        file   = "/run/secrets/google-subject-token"
        format = { type = "text" }
      }
      service_account_impersonation_url = data.terraform_remote_state.gcp.outputs.pageviewinfoga_impersonation_url
    })
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
