data "grafana_data_source" "prometheus" {
  name = "grafanacloud-femiwiki-prom"
}

data "grafana_data_source" "loki" {
  name = "grafanacloud-femiwiki-logs"
}

locals {
  discord_routes = {
    critical = {
      title           = "site-down-title.gotmpl"
      repeat_interval = "30m"
    }
    warning = {
      title           = "backup-stale-title.gotmpl"
      repeat_interval = "6h"
    }
  }
}

resource "grafana_notification_policy" "root" {
  contact_point   = "Discord"
  group_by        = ["alertname", "instance"]
  group_wait      = "30s"
  group_interval  = "5m"
  repeat_interval = "4h"

  dynamic "policy" {
    for_each = local.discord_routes

    content {
      matcher {
        label = "severity"
        match = "="
        value = policy.key
      }

      contact_point   = grafana_contact_point.discord[policy.key].name
      group_by        = ["alertname"]
      group_wait      = "30s"
      group_interval  = "5m"
      repeat_interval = policy.value.repeat_interval
    }
  }
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

data "grafana_folder" "femiwiki" {
  title = "Femiwiki"
}

locals {
  recent_status_url = "https://femiwiki.grafana.net/explore?panes=%7B%22a%22%3A%7B%22datasource%22%3A%22grafanacloud-logs%22%2C%22queries%22%3A%5B%7B%22datasource%22%3A%7B%22uid%22%3A%22grafanacloud-logs%22%7D%2C%22expr%22%3A%22sum+by+%28status%29+%28count_over_time%28%7Bdocker_container_name%3D~%5C%22http.%2A%5C%22%7D+%7C+json+%7C+__error__%3D%5C%22%5C%22+%7C+status+%21%3D+%5C%22%5C%22+%5B5m%5D%29%29%22%2C%22queryType%22%3A%22range%22%2C%22refId%22%3A%22A%22%7D%5D%2C%22range%22%3A%7B%22from%22%3A%22now-3h%22%2C%22to%22%3A%22now%22%7D%7D%7D&schemaVersion=1"

  successful_responses = trimspace(file("${path.module}/queries/site-down.logql"))

  recent_backup_url = "https://femiwiki.grafana.net/explore?panes=%7B%22a%22%3A%7B%22datasource%22%3A%22grafanacloud-logs%22%2C%22queries%22%3A%5B%7B%22datasource%22%3A%7B%22uid%22%3A%22grafanacloud-logs%22%7D%2C%22expr%22%3A%22%7Bdocker_container_name%3D%5C%22backupbot%5C%22%7D%22%2C%22queryType%22%3A%22range%22%2C%22refId%22%3A%22A%22%7D%5D%2C%22range%22%3A%7B%22from%22%3A%22now-7d%22%2C%22to%22%3A%22now%22%7D%7D%7D&schemaVersion=1"

  latest_backup_size = trimspace(file("${path.module}/queries/backup-stale.logql"))
}

resource "grafana_rule_group" "femiwiki_http" {
  name             = "http"
  folder_uid       = data.grafana_folder.femiwiki.uid
  interval_seconds = 60

  rule {
    name = "Site down"
    for  = "5m"

    condition      = "B"
    no_data_state  = "Alerting"
    exec_err_state = "OK"

    labels = {
      severity = "critical"
    }

    annotations = {
      summary = "최근 5분 동안 정상 응답이 {{ printf \"%.0f\" $values.A.Value }}건입니다."
      logs    = local.recent_status_url
    }

    data {
      ref_id         = "A"
      datasource_uid = data.grafana_data_source.loki.uid
      relative_time_range {
        from = 300
        to   = 0
      }
      model = jsonencode({
        refId     = "A"
        expr      = local.successful_responses
        queryType = "instant"
        instant   = true
        range     = false
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
        conditions = [{ evaluator = { type = "lt", params = [100] } }]
      })
    }
  }
}

resource "grafana_rule_group" "femiwiki_backup" {
  name             = "backup"
  folder_uid       = data.grafana_folder.femiwiki.uid
  interval_seconds = 600

  rule {
    name = "Backup stale"
    for  = "30m"

    condition      = "B"
    no_data_state  = "Alerting"
    exec_err_state = "OK"

    labels = {
      severity = "warning"
    }

    annotations = {
      summary = "하루 사이 올라온 데이터베이스 덤프가 {{ printf \"%.0f\" $values.A.Value }} MiB입니다."
      logs    = local.recent_backup_url
    }

    data {
      ref_id         = "A"
      datasource_uid = data.grafana_data_source.loki.uid
      relative_time_range {
        from = 93600
        to   = 0
      }
      model = jsonencode({
        refId     = "A"
        expr      = local.latest_backup_size
        queryType = "instant"
        instant   = true
        range     = false
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
        conditions = [{ evaluator = { type = "lt", params = [500] } }]
      })
    }
  }
}

resource "grafana_contact_point" "discord" {
  for_each = local.discord_routes

  name = "Discord ${each.key}"

  discord {
    url                  = var.discord_webhook_url
    use_discord_username = false

    title = trimspace(file("${path.module}/templates/${each.value.title}"))
    message = trimspace(replace(
      file("${path.module}/templates/discord-message.gotmpl"),
      "__MENTION_ROLE__",
      var.discord_mention_role_id,
    ))
  }
}

moved {
  from = grafana_contact_point.site_down
  to   = grafana_contact_point.discord["critical"]
}
