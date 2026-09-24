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

locals {
  incidents = {
    "2026-09-21" = {
      text     = "<a href=\"https://femiwiki.github.io/%EA%B0%80%EC%9A%A9%EC%84%B1/2026%EB%85%84_9%EC%9B%94.html\">9월 21일 사고</a>"
      time     = "2026-09-21T03:15:00Z"
      time_end = "2026-09-21T14:03:00Z"
    }
    "2026-09-23" = {
      text     = "<a href=\"https://femiwiki.github.io/%EA%B0%80%EC%9A%A9%EC%84%B1/2026%EB%85%84_9%EC%9B%94.html\">9월 23일 사고</a>"
      time     = "2026-09-23T13:30:00Z"
      time_end = "2026-09-23T23:47:00Z"
    }
  }
}

resource "grafana_annotation" "incident" {
  for_each = local.incidents

  dashboard_uid = grafana_dashboard.availability.uid
  text          = each.value.text
  time          = each.value.time
  time_end      = each.value.time_end
  tags          = ["사고"]
}
