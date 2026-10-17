# Two pages from two probes every two minutes: 86,400 runs a month, under the
# free plan's 100,000.
data "grafana_cloud_stack" "femiwiki" {
  provider = grafana.cloud
  slug     = "femiwiki"
}

resource "grafana_cloud_access_policy" "synthetics" {
  provider = grafana.cloud

  region = data.grafana_cloud_stack.femiwiki.region_slug
  name   = "synthetic-monitoring"
  scopes = ["metrics:write", "stacks:read", "logs:write", "traces:write"]

  realm {
    type       = "stack"
    identifier = data.grafana_cloud_stack.femiwiki.id
  }
}

resource "grafana_cloud_access_policy_token" "synthetics" {
  provider = grafana.cloud

  region           = data.grafana_cloud_stack.femiwiki.region_slug
  access_policy_id = grafana_cloud_access_policy.synthetics.policy_id
  name             = "synthetic-monitoring"
}

resource "grafana_synthetic_monitoring_installation" "femiwiki" {
  provider = grafana.cloud

  stack_id              = data.grafana_cloud_stack.femiwiki.id
  metrics_publisher_key = grafana_cloud_access_policy_token.synthetics.token
}

data "grafana_synthetic_monitoring_probes" "public" {
  provider   = grafana.sm
  depends_on = [grafana_synthetic_monitoring_installation.femiwiki]
}

locals {
  # 특수:빈문서 is never cached, so it fails whenever PHP cannot answer.
  synthetic_pages = ["페미위키:대문", "특수:빈문서"]
}

resource "grafana_synthetic_monitoring_check" "pages" {
  provider = grafana.sm
  for_each = toset(local.synthetic_pages)

  job        = each.key
  target     = "https://femiwiki.com/w/${urlencode(each.key)}"
  folder_uid = data.grafana_folder.femiwiki.uid
  frequency  = 120000
  timeout    = 4000
  probes = [
    data.grafana_synthetic_monitoring_probes.public.probes.Seoul,
    data.grafana_synthetic_monitoring_probes.public.probes.Tokyo,
  ]

  settings {
    http {
      fail_if_not_ssl = true
    }
  }
}
