locals {
  proxysql_admin_port       = 6032
  proxysql_proxy_port       = 6033
  proxysql_writer_hostgroup = 10
  proxysql_max_connections  = 30
  proxysql_park_ms          = 30000
  proxysql_server_version   = "8.0.43"

  proxysql_config_install = templatefile("res/install-proxysql-config.sh.tftpl", {
    region           = data.aws_region.current.region
    admin_port       = local.proxysql_admin_port
    proxy_port       = local.proxysql_proxy_port
    server_version   = local.proxysql_server_version
    park_ms          = local.proxysql_park_ms
    writer           = aws_instance.database_4.private_ip
    writer_hostgroup = local.proxysql_writer_hostgroup
    max_connections  = local.proxysql_max_connections
  })
}

resource "aws_ssm_document" "proxysql_config" {
  name            = "install-proxysql-config"
  document_type   = "Command"
  document_format = "JSON"

  content = jsonencode({
    schemaVersion = "2.2"
    description   = "Write /etc/femiwiki/proxysql.cnf from Parameter Store, so the credentials never pass through Terraform state."
    mainSteps = [{
      action = "aws:runShellScript"
      name   = "installProxysqlConfig"
      inputs = {
        runCommand = split("\n", local.proxysql_config_install)
      }
    }]
  })
}

resource "aws_ssm_association" "proxysql_config" {
  association_name    = "install-proxysql-config"
  name                = aws_ssm_document.proxysql_config.name
  document_version    = aws_ssm_document.proxysql_config.latest_version
  schedule_expression = "rate(30 minutes)"
  compliance_severity = "HIGH"
  max_concurrency     = "1"
  max_errors          = "0"

  targets {
    key    = "tag:Name"
    values = ["docker"]
  }
}
