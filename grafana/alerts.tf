data "grafana_data_source" "prometheus" {
  name = "grafanacloud-femiwiki-prom"
}

resource "grafana_notification_policy" "root" {
  contact_point   = "Discord"
  group_by        = ["alertname", "instance"]
  group_wait      = "30s"
  group_interval  = "5m"
  repeat_interval = "4h"
}

resource "grafana_folder" "hosts" {
  title = "Hosts"
}

locals {
  hosts_rules = {
    "Disk almost full" = {
      expr    = "100 * node_filesystem_avail_bytes{job=\"integrations/node_exporter\", mountpoint=\"/\"} / node_filesystem_size_bytes{job=\"integrations/node_exporter\", mountpoint=\"/\"}"
      below   = 10
      for     = "10m"
      summary = "{{ $labels.instance }}: {{ printf \"%.0f\" $values.A.Value }}% of / left"
      no_data = "Alerting"
    }
    "Memory almost gone" = {
      expr    = "node_memory_MemAvailable_bytes{job=\"integrations/node_exporter\"} / 1024 / 1024"
      below   = 100
      for     = "15m"
      summary = "{{ $labels.instance }}: {{ printf \"%.0f\" $values.A.Value }} MB available"
      no_data = "NoData"
    }
  }
}

resource "grafana_rule_group" "hosts" {
  name             = "hosts"
  folder_uid       = grafana_folder.hosts.uid
  interval_seconds = 60

  dynamic "rule" {
    for_each = local.hosts_rules
    content {
      name          = rule.key
      for           = rule.value.for
      condition     = "B"
      no_data_state = rule.value.no_data
      annotations = {
        summary = rule.value.summary
      }

      data {
        ref_id         = "A"
        datasource_uid = data.grafana_data_source.prometheus.uid
        relative_time_range {
          from = 300
          to   = 0
        }
        model = jsonencode({
          refId   = "A"
          expr    = rule.value.expr
          instant = true
          range   = false
        })
      }

      data {
        ref_id         = "B"
        datasource_uid = "__expr__"
        relative_time_range {
          from = 0
          to   = 0
        }
        model = jsonencode({
          refId      = "B"
          type       = "threshold"
          expression = "A"
          conditions = [{ evaluator = { type = "lt", params = [rule.value.below] } }]
        })
      }
    }
  }
}
