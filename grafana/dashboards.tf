resource "grafana_dashboard" "container_memory" {
  folder = data.grafana_folder.femiwiki.uid

  config_json = replace(
    jsonencode(yamldecode(file("${path.module}/dashboards/container-memory.yaml"))),
    "__PROM_UID__",
    data.grafana_data_source.prometheus.uid
  )
}

resource "grafana_dashboard" "site" {
  folder = data.grafana_folder.femiwiki.uid

  config_json = replace(
    jsonencode(yamldecode(file("${path.module}/dashboards/site.yaml"))),
    "__PROM_UID__",
    data.grafana_data_source.prometheus.uid
  )
}

resource "grafana_dashboard_public" "site" {
  dashboard_uid          = grafana_dashboard.site.uid
  is_enabled             = true
  share                  = "public"
  time_selection_enabled = true
}

resource "grafana_dashboard_public" "container_memory" {
  dashboard_uid          = grafana_dashboard.container_memory.uid
  is_enabled             = true
  share                  = "public"
  time_selection_enabled = true
}

resource "grafana_dashboard" "availability" {
  folder = data.grafana_folder.femiwiki.uid

  config_json = replace(
    jsonencode(yamldecode(file("${path.module}/dashboards/availability.yaml"))),
    "__PROM_UID__",
    data.grafana_data_source.prometheus.uid
  )
}

resource "grafana_dashboard_public" "availability" {
  dashboard_uid          = grafana_dashboard.availability.uid
  is_enabled             = true
  share                  = "public"
  time_selection_enabled = false
  annotations_enabled    = true
}

