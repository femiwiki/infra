data "aws_ssm_parameters_by_path" "mysql" {
  path      = "/mysql/"
  recursive = true
}

data "aws_ssm_parameters_by_path" "mediawiki" {
  path      = "/mediawiki/"
  recursive = true
}

# The check lives in the healthchecks workspace and its ping URL is only known
# there, so it comes across the way Terraform Cloud hands one workspace's
# outputs to another. backupbot reads the parameter when its container starts.
data "terraform_remote_state" "healthchecks" {
  backend = "s3"

  config = {
    bucket = aws_s3_bucket.tfstate.bucket
    key    = "healthchecks/terraform.tfstate"
    region = data.aws_region.current.region
  }
}

resource "aws_ssm_parameter" "mysql_backup_healthcheck_url" {
  name  = "/mysql/backup/healthcheck-url"
  type  = "SecureString"
  value = data.terraform_remote_state.healthchecks.outputs.mysql_backup_ping_url
}

locals {
  alloy_hosts = {
    database = "mysql"
    docker   = "femiwiki"
  }

  alloy_install = {
    for tag, name in local.alloy_hosts : tag => replace(
      replace(file("res/install-alloy-config.sh"), "__REGION__", data.aws_region.current.region),
      "__CONFIG__",
      templatefile("res/config.alloy.tftpl", {
        name                = name
        prometheus_endpoint = "https://prometheus-prod-49-prod-ap-northeast-0.grafana.net/api/prom/push"
        prometheus_username = "1835631"
        loki_endpoint       = "https://logs-prod-030.grafana.net/loki/api/v1/push"
        loki_username       = "1017101"
      })
    )
  }
}

resource "aws_ssm_parameter" "alloy" {
  for_each = {
    loki_password       = var.loki_password
    prometheus_password = var.prometheus_password
  }

  name  = "/alloy/${each.key}"
  type  = "SecureString"
  value = each.value
}

locals {
  swapfile_mib = 1024

  swapfile_install = replace(file("res/install-swapfile.sh"), "__SIZE_MIB__", local.swapfile_mib)
}

resource "aws_ssm_document" "swapfile" {
  name            = "install-swapfile"
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
  association_name    = "install-swapfile"
  name                = aws_ssm_document.swapfile.name
  document_version    = aws_ssm_document.swapfile.latest_version
  schedule_expression = "rate(30 minutes)"
  compliance_severity = "HIGH"
  max_concurrency     = "1"
  max_errors          = "0"

  targets {
    key    = "tag:Name"
    values = ["docker"]
  }
}

resource "aws_ssm_document" "alloy_config" {
  for_each = local.alloy_hosts

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

  depends_on = [aws_ssm_parameter.alloy]

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
