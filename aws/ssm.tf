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
  alloy_hosts = {
    "database" = { name = "mariadb-seoul", type = "database", region = local.seoul_region, tag = "Role" }
    "docker"   = { name = "femiwiki-seoul", type = "app", region = local.seoul_region, tag = "Name" }
  }

  alloy_grafana = {
    prometheus_endpoint = "https://prometheus-prod-49-prod-ap-northeast-0.grafana.net/api/prom/push"
    prometheus_username = "1835631"
    loki_endpoint       = "https://logs-prod-030.grafana.net/loki/api/v1/push"
    loki_username       = "1017101"
    pyroscope_endpoint  = "https://profiles-prod-019.grafana.net"
    pyroscope_username  = "1059321"
  }

  alloy_install = {
    for tag, host in local.alloy_config_hosts : tag => replace(
      replace(file("res/install-alloy-config.sh"), "__REGION__", host.region),
      "__CONFIG__",
      templatefile("res/config.alloy.tftpl", merge(local.alloy_grafana, { name = host.name, type = host.type }))
    )
  }
}

# Taking over from Alloy one signal at a time (#1259). Alloy is removed from a
# host once the Collector carries everything it sent.
locals {
  otelcol_hosts = local.alloy_hosts
  alloy_retired = toset(["database"])

  alloy_config_hosts = { for tag, host in local.alloy_hosts : tag => host if !contains(local.alloy_retired, tag) }

  otelcol_version       = "0.162.0"
  otelcol_sha256        = "cc005e793ec6f029d1a1627d656db998298dd5a8a8f9d25a13e555116e93e1ea"
  node_exporter_version = "1.12.1"
  node_exporter_sha256  = "ad35b605f9954b9f1ffddf5ba054bdc5a98d790b9eae5291e1eeb83f1ecbd0e7"

  otelcol_install = {
    for tag, host in local.otelcol_hosts : tag => replace(replace(replace(replace(replace(replace(replace(
      file("res/install-otelcol.sh"),
      "__REGION__", host.region),
      "__OTELCOL_VERSION__", local.otelcol_version),
      "__OTELCOL_SHA256__", local.otelcol_sha256),
      "__NODE_EXPORTER_VERSION__", local.node_exporter_version),
      "__NODE_EXPORTER_SHA256__", local.node_exporter_sha256),
      "__REMOVE_ALLOY__", contains(local.alloy_retired, tag) ? "1" : "0"),
      "__CONFIG__",
      templatefile("res/config.otelcol.yaml.tftpl", {
        name                = host.name
        type                = host.type
        prometheus_endpoint = local.alloy_grafana.prometheus_endpoint
        prometheus_username = local.alloy_grafana.prometheus_username
        loki_endpoint       = replace(local.alloy_grafana.loki_endpoint, "/loki/api/v1/push", "/otlp")
        loki_username       = local.alloy_grafana.loki_username
        pyroscope_endpoint  = local.alloy_grafana.pyroscope_endpoint
        pyroscope_username  = local.alloy_grafana.pyroscope_username
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

resource "aws_ssm_document" "alloy_config" {
  for_each = local.alloy_config_hosts

  region          = each.value.region
  name            = "install-alloy-config-${each.key}"
  document_type   = "Command"
  document_format = "JSON"

  content = jsonencode({
    schemaVersion = "2.2"
    description   = "Install /etc/alloy/config.alloy and the credentials it reads, then reload Alloy."
    mainSteps = [{
      action = "aws:runShellScript"
      name   = "installAlloyConfig"
      inputs = {
        runCommand = split("\n", local.alloy_install[each.key])
      }
    }]
  })
}

moved {
  from = aws_ssm_document.alloy_config["database-5"]
  to   = aws_ssm_document.alloy_config["database"]
}

moved {
  from = aws_ssm_association.alloy_config["database-5"]
  to   = aws_ssm_association.alloy_config["database"]
}

resource "aws_ssm_association" "alloy_config" {
  for_each = local.alloy_config_hosts

  depends_on = [aws_ssm_parameter.alloy_seoul]

  region              = each.value.region
  association_name    = "install-alloy-config-${each.key}"
  name                = aws_ssm_document.alloy_config[each.key].name
  document_version    = aws_ssm_document.alloy_config[each.key].latest_version
  schedule_expression = "rate(30 minutes)"
  compliance_severity = "HIGH"
  max_concurrency     = "1"
  max_errors          = "0"

  targets {
    key    = "tag:${each.value.tag}"
    values = [each.key]
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

  depends_on = [aws_ssm_parameter.alloy_seoul]

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
