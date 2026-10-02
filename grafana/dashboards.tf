locals {
  dashboards = {
    "container-memory" = { public = true, folder = grafana_folder.hosts.uid, time_selection = true, annotations = false }
    "site"             = { public = true, folder = data.grafana_folder.femiwiki.uid, time_selection = true, annotations = false }
    "scrapes"          = { public = false, folder = data.grafana_folder.femiwiki.uid, time_selection = false, annotations = false }
  }

  dashboard_configs = {
    for name in concat(keys(local.dashboards), ["availability"]) : name => replace(
      replace(
        jsonencode(yamldecode(file("${path.module}/dashboards/${name}.yaml"))),
        "__PROM_UID__",
        data.grafana_data_source.prometheus.uid
      ),
      "__LOKI_UID__",
      data.grafana_data_source.loki.uid
    )
  }

  public_dashboard_urls = {
    for name, board in grafana_dashboard_public.this :
    name => "https://femiwiki.grafana.net/public-dashboards/${board.access_token}"
  }
}

resource "grafana_dashboard" "this" {
  for_each = local.dashboards

  folder      = each.value.folder
  config_json = local.dashboard_configs[each.key]
}

resource "grafana_dashboard_public" "this" {
  for_each = { for name, board in local.dashboards : name => board if board.public }

  dashboard_uid          = grafana_dashboard.this[each.key].uid
  is_enabled             = true
  share                  = "public"
  time_selection_enabled = each.value.time_selection
  annotations_enabled    = each.value.annotations
}

# Kept out of the map above because it links to the other public boards,
# whose addresses exist only once they are shared.
resource "grafana_dashboard" "availability" {
  folder = data.grafana_folder.femiwiki.uid
  config_json = replace(
    local.dashboard_configs["availability"],
    "__PUBLIC_LINKS__",
    join(" · ", [
      for name, url in local.public_dashboard_urls :
      "[${yamldecode(file("${path.module}/dashboards/${name}.yaml")).title}](${url})"
    ])
  )
}

resource "grafana_dashboard_public" "availability" {
  dashboard_uid          = grafana_dashboard.availability.uid
  is_enabled             = true
  share                  = "public"
  time_selection_enabled = false
  annotations_enabled    = true
}

moved {
  from = grafana_dashboard.this["availability"]
  to   = grafana_dashboard.availability
}

moved {
  from = grafana_dashboard_public.this["availability"]
  to   = grafana_dashboard_public.availability
}
