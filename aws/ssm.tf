# The check lives in the healthchecks workspace and its ping URL is only known
# there, so it comes across the way Terraform Cloud hands one workspace's
# outputs to another. The database host reads the parameter when the dump
# installer runs.
data "terraform_remote_state" "healthchecks" {
  backend = "s3"

  config = {
    bucket = aws_s3_bucket.tfstate.bucket
    key    = "healthchecks/terraform.tfstate"
    region = local.tokyo_region
  }
}

data "terraform_remote_state" "gcp" {
  backend = "s3"

  config = {
    bucket = aws_s3_bucket.tfstate.bucket
    key    = "gcp/terraform.tfstate"
    region = local.tokyo_region
  }
}

locals {
  alloy_hosts = {
    "database-5" = { name = "mariadb-seoul", type = "database", region = local.seoul_region }
    "docker"     = { name = "femiwiki-seoul", type = "app", region = local.seoul_region }
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
    for tag, host in local.alloy_hosts : tag => replace(
      replace(file("res/install-alloy-config.sh"), "__REGION__", host.region),
      "__CONFIG__",
      templatefile("res/config.alloy.tftpl", merge(local.alloy_grafana, { name = host.name, type = host.type }))
    )
  }
}

locals {
  app_hosts = {
    "docker" = { region = local.seoul_region }
  }

  mysql_backup_script = templatefile("res/mysql-backup.sh.tftpl", {
    region         = local.seoul_region
    backups_bucket = aws_s3_bucket.backups_seoul.bucket
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

  swapfile_install = replace(file("res/install-swapfile.sh"), "__SIZE_MIB__", local.swapfile_mib)
}

locals {
  prune_keep_hours = 72

  prune_images = replace(file("res/prune-docker-images.sh"), "__KEEP_HOURS__", local.prune_keep_hours)
}

resource "aws_ssm_document" "prune_docker_images" {
  for_each = local.app_hosts

  region          = each.value.region
  name            = "prune-docker-images-${each.key}"
  document_type   = "Command"
  document_format = "JSON"

  content = jsonencode({
    schemaVersion = "2.2"
    description   = "Remove the docker images and anonymous volumes no container uses, so deploys stop filling the root volume."
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
  schedule_expression = "cron(0 18 ? * * *)"
  compliance_severity = "MEDIUM"
  max_concurrency     = "1"
  max_errors          = "0"

  targets {
    key    = "tag:Name"
    values = [each.key]
  }
}

resource "aws_ssm_document" "swapfile" {
  for_each = local.app_hosts

  region          = each.value.region
  name            = "install-swapfile-${each.key}"
  document_type   = "Command"
  document_format = "JSON"

  content = jsonencode({
    schemaVersion = "2.2"
    description   = "Give the docker host a swap file, so a container swap does not end in an OOM kill."
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
  for_each = local.app_hosts

  region              = each.value.region
  association_name    = "install-swapfile-${each.key}"
  name                = aws_ssm_document.swapfile[each.key].name
  document_version    = aws_ssm_document.swapfile[each.key].latest_version
  schedule_expression = "rate(30 minutes)"
  compliance_severity = "HIGH"
  max_concurrency     = "1"
  max_errors          = "0"

  targets {
    key    = "tag:Name"
    values = [each.key]
  }
}

resource "aws_ssm_document" "alloy_config" {
  for_each = local.alloy_hosts

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

resource "aws_ssm_association" "alloy_config" {
  for_each = local.alloy_hosts

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
    key    = "tag:Name"
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
