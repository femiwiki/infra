locals {
  dashboards = {
    "container-memory" = { folder = grafana_folder.hosts.uid, time_selection = true, annotations = false }
    "site"             = { folder = data.grafana_folder.femiwiki.uid, time_selection = true, annotations = false }
    "availability"     = { folder = data.grafana_folder.femiwiki.uid, time_selection = false, annotations = true }
  }
}

resource "grafana_dashboard" "this" {
  for_each = local.dashboards

  folder = each.value.folder

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
