locals {
  # Classic femiwiki image used by BOTH the edge Caddy (`http`) and the cron singleton.
  #
  # MUST be a REBUILT image that ships the NEW reverse_proxy Caddyfile
  # (dockers/femiwiki/Caddyfile, section 5). Build + push that image and confirm its
  # Caddyfile adapts (validation section 8) BEFORE applying this workspace: removing
  # FASTCGI_ADDR while the OLD php_fastcgi Caddyfile is still baked makes `php_fastcgi`
  # expand with no upstream -> adapt error -> Caddy fails to start -> edge DOWN.
  # Pin by @sha256: digest in production.
  femiwiki_image = "ghcr.io/femiwiki/femiwiki:2026-06-28T17-00-NEWCADDY"
}

resource "docker_container" "http" {
  name            = "http"
  image           = local.femiwiki_image
  command         = ["caddy", "run"]
  restart         = "on-failure"
  max_retry_count = 3
  network_mode    = "host"

  env = [
    for k, v in {
      # No local php-fpm anymore: the Caddyfile uses reverse_proxy. This is only the
      # bootstrap SEED for the @id=backend_upstreams handler; the edge reconciler owns the
      # live set via the admin API. Points at a dead local port on purpose (handle_errors
      # in the Caddyfile serves a maintenance page until the first reconcile PATCH lands).
      BACKEND_UPSTREAMS   = "127.0.0.1:8080",
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
}

#
# Cron SINGLETON (edge). The ONLY job runner in the whole system: ASG nodes serve only
# ($wgJobRunRate=0, FrankenPHP image forbids cron). Runs run-jobs / generate-sitemap /
# update-special-pages against the shared MySQL + edge memcached. NEVER serves HTTP.
#
resource "docker_container" "cron" {
  name         = "cron"
  image        = local.femiwiki_image
  network_mode = "host"
  restart      = "always"

  # Mirrors dockers/femiwiki/run (LocalSettings + Hotfix), then runs cron in the foreground.
  # The image installs the schedule as ROOT'S USER CRONTAB at build time
  # (mediawiki/Dockerfile: `RUN crontab /tmp/crontab`), so `crontab -l` lists the 3 jobs.
  # CRITICAL env->cron bridge: each job loads LocalSettings.php which reads ALL config via
  # getenv() (WG_DB_*/WG_SECRET_KEY/...), but cron SCRUBS the environment. `export -p`
  # serializes the container env (multiline/PEM-safe) into BASH_ENV; SHELL=/bin/bash is
  # required (default /bin/sh=dash ignores BASH_ENV). Guarded so a missing user crontab
  # cannot crash-loop the container, and asserted afterward.
  command = ["/bin/bash", "-c", <<-EOT
    set -euo pipefail
    cp -f /a/LocalSettings.php /srv/femiwiki.com/LocalSettings.php
    printf '%s' "$MEDIAWIKI_HOTFIX_SNIPPET" > /a/Hotfix.php
    mkdir -p /run/femiwiki
    export -p > /run/femiwiki/cron.env
    existing="$(crontab -l 2>/dev/null || true)"
    { printf 'SHELL=/bin/bash\nBASH_ENV=/run/femiwiki/cron.env\n'; printf '%s\n' "$existing"; } | crontab -
    crontab -l | grep -q run-jobs || { echo 'FATAL: run-jobs missing from crontab' >&2; exit 1; }
    exec cron -f
  EOT
  ]

  env = [
    for k, v in {
      MEDIAWIKI_SKIP_IMPORT_SITES = "1"
      MEDIAWIKI_SKIP_INSTALL      = "1"
      MEDIAWIKI_SKIP_UPDATE       = "1" # mandatory: cron must never run update.php (no DDL drift)
      MEDIAWIKI_HOTFIX_SNIPPET    = file("res/Hotfix.php")

      WG_BOUNCE_HANDLER_INTERNAL_IPS = "172.31.0.0/16"
      WG_CDN_SERVERS                 = "127.0.0.1:80" # edge Caddy (host net)
      WG_INTERNAL_SERVER             = "http://127.0.0.1:80"
      WG_MEMCACHED_SERVERS           = "127.0.0.1:11211" # edge memcached (host net)

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

  # Owns the sitemap volume RW (takes over from the deleted fastcgi). generate-sitemap
  # writes `--fspath sitemap` into /srv/femiwiki.com/sitemap; the edge `http` serves it RO.
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
