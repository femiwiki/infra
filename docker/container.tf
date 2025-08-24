resource "docker_container" "http" {
  count           = 0
  name            = "http"
  image           = "ghcr.io/femiwiki/femiwiki:2025-05-24t17-47-df7f1357"
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
    type   = "bind"
    source = "/srv/femiwiki.com/Caddyfile"
    target = "/srv/femiwiki.com/Caddyfile"
  }

  mounts {
    type   = "bind"
    source = "/srv/femiwiki.com/robots.txt"
    target = "/srv/femiwiki.com/robots.txt"
  }

  mounts {
    type   = "bind"
    source = "/srv/femiwiki.com/sitemap"
    target = "/srv/femiwiki.com/sitemap"
  }

  ulimit {
    hard = 65536
    name = "nofile"
    soft = 32768
  }
}

resource "docker_container" "fastcgi" {
  count        = 0
  name         = "fastcgi"
  image        = "ghcr.io/femiwiki/femiwiki:2025-08-24t05-34-3a83d349"
  network_mode = "host"
  restart      = "always"
  env = [
    "MEDIAWIKI_SKIP_IMPORT_SITES=1",
    "MEDIAWIKI_SKIP_INSTALL=1",
    "MEDIAWIKI_SKIP_UPDATE=1",
    "WG_CDN_SERVERS=127.0.0.1:80",
    "WG_DB_SERVER=127.0.0.1:3306",
    "WG_DB_USER=mediawiki",
    "DB_PASSWORD_FILE=/run/secrets/db_user_password",
    "WG_INTERNAL_SERVER=http://127.0.0.1:80",
    "WG_MEMCACHED_SERVERS=127.0.0.1:11211",
    # Used by fcgi-probe.php
    "FCGI_URL=127.0.0.1:9000",
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
    type   = "volume"
    target = "/a"
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

resource "docker_container" "mysql" {
  count = 0
  name  = "mysql"
  image = "mysql/mysql-server:8.0.32"
  env = [
    "MYSQL_RANDOM_ROOT_PASSWORD=yes",
    # "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
    # "MYSQL_UNIX_PORT=/var/lib/mysql/mysql.sock"
  ]
  network_mode = "host"
  restart      = "always"

  mounts {
    type   = "bind"
    source = "/srv/mysql"
    target = "/srv/mysql"
  }

  mounts {
    type   = "bind"
    source = "/etc/mysql"
    target = "/etc/mysql"
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

  lifecycle {
    ignore_changes = [env]
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
