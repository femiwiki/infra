# The check lives in the healthchecks workspace and its ping URL is only known
# there, so it comes across the way Terraform Cloud hands one workspace's
# outputs to another. The database host reads the parameter when the dump
# installer runs.
data "terraform_remote_state" "healthchecks" {
  backend = "s3"

  config = {
    bucket = module.state.s3_bucket_id
    key    = "healthchecks/terraform.tfstate"
    region = module.state.s3_bucket_region
  }
}

data "terraform_remote_state" "gcp" {
  backend = "s3"

  config = {
    bucket = module.state.s3_bucket_id
    key    = "gcp/terraform.tfstate"
    region = module.state.s3_bucket_region
  }
}

locals {
  # Database hosts come and go with the swap, so they are found by role.
  otelcol_hosts = {
    "database" = { name = "mariadb-seoul", type = "database", region = local.seoul_region, tag = "Role" }
    "docker"   = { name = "femiwiki-seoul", type = "app", region = local.seoul_region, tag = "Name" }
  }

  grafana_cloud = {
    prometheus_endpoint = "https://prometheus-prod-49-prod-ap-northeast-0.grafana.net/api/prom/push"
    prometheus_username = "1835631"
    loki_endpoint       = "https://logs-prod-030.grafana.net/loki/api/v1/push"
    loki_username       = "1017101"
    pyroscope_endpoint  = "https://profiles-prod-019.grafana.net"
    pyroscope_username  = "1059321"
  }
}

locals {
  otelcol_version       = "0.162.0"
  otelcol_sha256        = "cc005e793ec6f029d1a1627d656db998298dd5a8a8f9d25a13e555116e93e1ea"
  node_exporter_version = "1.12.1"
  node_exporter_sha256  = "ad35b605f9954b9f1ffddf5ba054bdc5a98d790b9eae5291e1eeb83f1ecbd0e7"

  otelcol_install = {
    for tag, host in local.otelcol_hosts : tag => replace(replace(replace(replace(replace(replace(
      file("res/install-otelcol.sh"),
      "__REGION__", host.region),
      "__OTELCOL_VERSION__", local.otelcol_version),
      "__OTELCOL_SHA256__", local.otelcol_sha256),
      "__NODE_EXPORTER_VERSION__", local.node_exporter_version),
      "__NODE_EXPORTER_SHA256__", local.node_exporter_sha256),
      "__CONFIG__",
      templatefile("res/config.otelcol.yaml.tftpl", {
        name                = host.name
        type                = host.type
        prometheus_endpoint = local.grafana_cloud.prometheus_endpoint
        prometheus_username = local.grafana_cloud.prometheus_username
        loki_endpoint       = replace(local.grafana_cloud.loki_endpoint, "/loki/api/v1/push", "/otlp")
        loki_username       = local.grafana_cloud.loki_username
        pyroscope_endpoint  = local.grafana_cloud.pyroscope_endpoint
        pyroscope_username  = local.grafana_cloud.pyroscope_username
      })
    )
  }
}

locals {
  app_hosts = {
    "docker" = { region = local.seoul_region }
  }

  mysql_backup_script = templatefile("res/mysql-backup.sh.tftpl", {
    region         = local.seoul_region
    backups_bucket = module.backups_seoul.s3_bucket_id
  })

  mysql_backup_install = templatefile("res/install-mysql-backup.sh.tftpl", {
    parameter_region = local.seoul_region
    backup_script    = local.mysql_backup_script
  })
}

resource "aws_ssm_document" "mysql_backup" {
  region          = local.seoul_region
  name            = "install-mysql-backup"
  document_type   = "Command"
  document_format = "JSON"

  content = jsonencode({
    schemaVersion = "2.2"
    description   = "Install /usr/local/sbin/mysql-backup, the credentials it pings with, and its timer."
    mainSteps = [{
      action = "aws:runShellScript"
      name   = "installMysqlBackup"
      inputs = {
        runCommand = split("\n", local.mysql_backup_install)
      }
    }]
  })
}

resource "aws_ssm_association" "mysql_backup" {
  depends_on = [aws_ssm_parameter.mysql_backup_healthcheck_url]

  region              = local.seoul_region
  association_name    = "install-mysql-backup"
  name                = aws_ssm_document.mysql_backup.name
  document_version    = aws_ssm_document.mysql_backup.latest_version
  schedule_expression = "rate(30 minutes)"
  compliance_severity = "HIGH"
  max_concurrency     = "1"
  max_errors          = "0"

  # The role, not the host. Targeting tag:Name meant the association named
  # whichever host happened to be the primary, and a promotion left the timer
  # installed on the host it moved away from: on 2026-09-27 that would have
  # uploaded a copy frozen at the switchover and pinged the check for it.
  targets {
    key    = "tag:MysqlBackup"
    values = ["true"]
  }
}

locals {
  swapfile_mib = 1024

  # Database hosts come and go with the replacement workflow, so they are
  # found by role.
  swapfile_hosts = {
    "docker"   = { region = local.seoul_region, tag = "Name", value = "docker" }
    "database" = { region = local.seoul_region, tag = "Role", value = "database" }
  }

  swapfile_install = replace(file("res/install-swapfile.sh"), "__SIZE_MIB__", local.swapfile_mib)
}

locals {
  # The image just pulled for a deploy is the newest, so it is kept even before
  # its container exists
  prune_keep_recent = 3

  prune_images = replace(file("res/prune-docker-images.sh"), "__KEEP_RECENT__", local.prune_keep_recent)
}

resource "aws_ssm_document" "prune_docker_images" {
  for_each = local.app_hosts

  region          = each.value.region
  name            = "prune-docker-images-${each.key}"
  document_type   = "Command"
  document_format = "JSON"

  content = jsonencode({
    schemaVersion = "2.2"
    description   = "Keep the newest docker images and those containers use, and remove the rest with any orphaned anonymous volumes, so deploys stop filling the root volume."
    mainSteps = [{
      action = "aws:runShellScript"
      name   = "pruneDockerImages"
      inputs = {
        runCommand = split("\n", local.prune_images)
      }
    }]
  })
}

resource "aws_ssm_association" "prune_docker_images" {
  for_each = local.app_hosts

  region              = each.value.region
  association_name    = "prune-docker-images-${each.key}"
  name                = aws_ssm_document.prune_docker_images[each.key].name
  document_version    = aws_ssm_document.prune_docker_images[each.key].latest_version
  schedule_expression = "cron(0 0 0/4 1/1 * ? *)"
  compliance_severity = "MEDIUM"
  max_concurrency     = "1"
  max_errors          = "0"

  targets {
    key    = "tag:Name"
    values = [each.key]
  }
}

resource "aws_ssm_document" "swapfile" {
  for_each = local.swapfile_hosts

  region          = each.value.region
  name            = "install-swapfile-${each.key}"
  document_type   = "Command"
  document_format = "JSON"

  content = jsonencode({
    schemaVersion = "2.2"
    description   = "Give the host a swap file, so running short of memory slows it down instead of stopping it."
    mainSteps = [{
      action = "aws:runShellScript"
      name   = "installSwapfile"
      inputs = {
        runCommand = split("\n", local.swapfile_install)
      }
    }]
  })
}

resource "aws_ssm_association" "swapfile" {
  for_each = local.swapfile_hosts

  region              = each.value.region
  association_name    = "install-swapfile-${each.key}"
  name                = aws_ssm_document.swapfile[each.key].name
  document_version    = aws_ssm_document.swapfile[each.key].latest_version
  schedule_expression = "rate(30 minutes)"
  compliance_severity = "HIGH"
  max_concurrency     = "1"
  max_errors          = "0"

  targets {
    key    = "tag:${each.value.tag}"
    values = [each.value.value]
  }
}

resource "aws_ssm_document" "otelcol" {
  for_each = local.otelcol_hosts

  region          = each.value.region
  name            = "install-otelcol-${each.key}"
  document_type   = "Command"
  document_format = "JSON"

  content = jsonencode({
    schemaVersion = "2.2"
    description   = "Install node_exporter and the OpenTelemetry Collector with its configuration and the credentials it reads, then reload the Collector."
    mainSteps = [{
      action = "aws:runShellScript"
      name   = "installOtelcol"
      inputs = {
        runCommand = split("\n", local.otelcol_install[each.key])
      }
    }]
  })
}

resource "aws_ssm_association" "otelcol" {
  for_each = local.otelcol_hosts

  depends_on = [aws_ssm_parameter.alloy]

  region              = each.value.region
  association_name    = "install-otelcol-${each.key}"
  name                = aws_ssm_document.otelcol[each.key].name
  document_version    = aws_ssm_document.otelcol[each.key].latest_version
  schedule_expression = "rate(30 minutes)"
  compliance_severity = "HIGH"
  max_concurrency     = "1"
  max_errors          = "0"

  targets {
    key    = "tag:${each.value.tag}"
    values = [each.key]
  }
}

# Steps 2 and 3 of the MediaWiki 1.46 upgrade (femiwiki/femiwiki#645), run by
# hand with Run Command. Nothing schedules them.
resource "aws_ssm_document" "copy_wiki_schema" {
  region          = local.seoul_region
  name            = "copy-wiki-schema"
  document_type   = "Command"
  document_format = "JSON"

  content = jsonencode({
    schemaVersion = "2.2"
    description   = "Copy the femiwiki schema into a new schema on the database host."
    parameters = {
      target = {
        type           = "String"
        description    = "Name of the new schema, such as femiwiki_43."
        allowedPattern = "^femiwiki_[0-9]+$"
      }
    }
    mainSteps = [{
      action = "aws:runShellScript"
      name   = "copyWikiSchema"
      inputs = {
        runCommand = split("\n", replace(file("res/copy-wiki-schema.sh"), "__TARGET__", "{{ target }}"))
      }
    }]
  })
}

resource "aws_ssm_document" "update_wiki_schema" {
  region          = local.seoul_region
  name            = "update-wiki-schema"
  document_type   = "Command"
  document_format = "JSON"

  content = jsonencode({
    schemaVersion = "2.2"
    description   = "Run a femiwiki image's update.php against a schema, on the docker host."
    parameters = {
      image = {
        type           = "String"
        description    = "Image whose update.php runs, such as ghcr.io/femiwiki/femiwiki:1.46-2026-10-02T23-35-fe1d33c2."
        allowedPattern = "^ghcr\\.io/femiwiki/femiwiki:[A-Za-z0-9._-]+$"
      }
      target = {
        type           = "String"
        description    = "Schema to update, such as femiwiki."
        allowedPattern = "^femiwiki(_[0-9]+)?$"
      }
    }
    mainSteps = [{
      action = "aws:runShellScript"
      name   = "updateWikiSchema"
      inputs = {
        runCommand = split("\n", replace(replace(file("res/update-wiki-schema.sh"), "__IMAGE__", "{{ image }}"), "__TARGET__", "{{ target }}"))
      }
    }]
  })
}

resource "aws_ssm_parameter" "mysql_backup_healthcheck_url" {
  region = local.seoul_region
  name   = "/mysql/backup/healthcheck-url"
  type   = "SecureString"
  value  = data.terraform_remote_state.healthchecks.outputs.mysql_backup_ping_url
}

resource "aws_ssm_document" "docker_api_readonly_forward" {
  region          = local.seoul_region
  name            = "forward-docker-api-readonly"
  document_type   = "Session"
  document_format = "JSON"

  content = jsonencode({
    schemaVersion = "1.0"
    description   = "Forwards the read-only Docker API on 127.0.0.1:2377 and no other port, for docker plans of pull requests."
    sessionType   = "Port"
    parameters = {
      localPortNumber = {
        type           = "String"
        description    = "The port on the client."
        allowedPattern = "^[0-9]{1,5}$"
        default        = "0"
      }
    }
    properties = {
      portNumber      = "2377"
      type            = "LocalPortForwarding"
      localPortNumber = "{{ localPortNumber }}"
    }
  })
}

resource "aws_ssm_document" "mariadb_forward" {
  region          = local.seoul_region
  name            = "forward-mariadb"
  document_type   = "Session"
  document_format = "JSON"

  content = jsonencode({
    schemaVersion = "1.0"
    description   = "Forwards MariaDB on 127.0.0.1:3306 and no other port, for mariadb plans of pull requests."
    sessionType   = "Port"
    parameters = {
      localPortNumber = {
        type           = "String"
        description    = "The port on the client."
        allowedPattern = "^[0-9]{1,5}$"
        default        = "0"
      }
    }
    properties = {
      portNumber      = "3306"
      type            = "LocalPortForwarding"
      localPortNumber = "{{ localPortNumber }}"
    }
  })
}

resource "aws_ssm_parameter" "alloy" {
  for_each = {
    loki_password       = var.loki_password
    prometheus_password = var.prometheus_password
  }

  region           = local.seoul_region
  name             = "/alloy/${each.key}"
  type             = "SecureString"
  value_wo         = each.value
  value_wo_version = 1
}

# Read by publish-dump in the MediaWiki image (femiwiki/docker-mediawiki#1235).
resource "aws_ssm_parameter" "internet_archive" {
  for_each = {
    access_key = var.internet_archive_access_key
    secret_key = var.internet_archive_secret_key
  }

  region           = local.seoul_region
  name             = "/mediawiki/internet_archive/${each.key}"
  type             = "SecureString"
  value_wo         = each.value
  value_wo_version = 1
}

# Read by the MediaWiki image's ConfirmEdit (femiwiki/femiwiki#668).
resource "aws_ssm_parameter" "h_captcha_secret_key" {
  region           = local.seoul_region
  name             = "/mediawiki/h_captcha/secret_key"
  type             = "SecureString"
  value_wo         = var.h_captcha_secret_key
  value_wo_version = 1
}

# Read by the MediaWiki image to send slow-request profiles; the profiles:write
# token is made by grafana/access-policies.tf (femiwiki/femiwiki#614).
resource "aws_ssm_parameter" "pyroscope_password" {
  region           = local.seoul_region
  name             = "/mediawiki/pyroscope/password"
  type             = "SecureString"
  value_wo         = var.pyroscope_password
  value_wo_version = 1
}

# Read without decryption, so their values stay out of the state. Written by hand
# (femiwiki/femiwiki#597), except the database logins, once random_password's.
locals {
  secret_parameters = toset([
    "/mariadb/users/repl/password",
    "/mediawiki/bounce_handler/token",
    "/mediawiki/o_auth_2_private_key",
    "/mediawiki/rc_feeds_discord_url",
    "/mediawiki/site_key",
    "/mediawiki/smtp/password",
    "/mediawiki/verp_secret",
    "/mysql/users/mediawiki/password",
    "/mysql/users/tofu-plan/password",
    "/mysql/users/tofu/password",
  ])
}

data "aws_ssm_parameter" "secret" {
  for_each = local.secret_parameters

  region          = local.seoul_region
  name            = each.key
  with_decryption = false
}

# The next database host's server_id, raised by the replacement workflow so no
# id comes back: a replica skips events that carry its own id.
resource "aws_ssm_parameter" "mariadb_next_server_id" {
  region = local.seoul_region
  name   = "/mariadb/server-id/next"
  type   = "String"
  value  = "6"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_document" "docker_socket_only" {
  region          = local.seoul_region
  name            = "docker-socket-only"
  document_type   = "Command"
  document_format = "JSON"

  content = jsonencode({
    schemaVersion = "2.2"
    description   = "Stop the Docker daemon listening on TCP, since applies reach its socket through ssh over SSM."
    mainSteps = [{
      action = "aws:runShellScript"
      name   = "dockerSocketOnly"
      inputs = {
        runCommand = split("\n", file("res/docker-socket-only.sh"))
      }
    }]
  })
}

resource "aws_ssm_association" "docker_socket_only" {
  region              = local.seoul_region
  association_name    = "docker-socket-only"
  name                = aws_ssm_document.docker_socket_only.name
  document_version    = aws_ssm_document.docker_socket_only.latest_version
  schedule_expression = "rate(30 minutes)"
  compliance_severity = "HIGH"
  max_concurrency     = "1"
  max_errors          = "0"

  targets {
    key    = "tag:Name"
    values = ["docker"]
  }
}
