locals {
  dashboards = {
    "container-memory" = { time_selection = true, annotations = false }
    "site"             = { time_selection = true, annotations = false }
    "availability"     = { time_selection = false, annotations = true }
  }
}

resource "grafana_dashboard" "this" {
  for_each = local.dashboards

  folder = data.grafana_folder.femiwiki.uid

  config_json = replace(
    jsonencode(yamldecode(file("${path.module}/dashboards/${each.key}.yaml"))),
    "__PROM_UID__",
    data.grafana_data_source.prometheus.uid
  )
}

resource "grafana_dashboard_public" "this" {
  for_each = local.dashboards

  dashboard_uid          = grafana_dashboard.this[each.key].uid
  is_enabled             = true
  share                  = "public"
  time_selection_enabled = each.value.time_selection
  annotations_enabled    = each.value.annotations
}

moved {
  from = grafana_dashboard.container_memory
  to   = grafana_dashboard.this["container-memory"]
}

moved {
  from = grafana_dashboard.site
  to   = grafana_dashboard.this["site"]
}

moved {
  from = grafana_dashboard.availability
  to   = grafana_dashboard.this["availability"]
}

moved {
  from = grafana_dashboard_public.container_memory
  to   = grafana_dashboard_public.this["container-memory"]
}

moved {
  from = grafana_dashboard_public.site
  to   = grafana_dashboard_public.this["site"]
}

moved {
  from = grafana_dashboard_public.availability
  to   = grafana_dashboard_public.this["availability"]
}
