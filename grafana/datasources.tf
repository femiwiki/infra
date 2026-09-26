data "grafana_data_source" "prometheus" {
  name = "grafanacloud-femiwiki-prom"
}

data "grafana_data_source" "loki" {
  name = "grafanacloud-femiwiki-logs"
}

data "grafana_data_source" "usage" {
  name = "grafanacloud-usage"
}

data "grafana_data_source" "infinity" {
  name = "grafanacloud-infinity"
}
