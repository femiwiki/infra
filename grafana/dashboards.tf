resource "grafana_dashboard" "container_memory" {
  folder = data.grafana_folder.femiwiki.uid

  config_json = replace(
    file("${path.module}/dashboards/container-memory.json"),
    "__PROM_UID__",
    data.grafana_data_source.prometheus.uid
  )
}
