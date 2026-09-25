data "grafana_data_source" "prometheus" {
  name = "grafanacloud-femiwiki-prom"
}

data "grafana_data_source" "loki" {
  name = "grafanacloud-femiwiki-logs"
}

locals {
  discord_contact_points = {
    critical = "site-down-title.gotmpl"
  }

  discord_routes = {
    critical = "30m"
  }
}

resource "grafana_notification_policy" "root" {
  contact_point   = grafana_contact_point.discord_default.name
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
      repeat_interval = policy.value
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

locals {
  memory_rules = {
    "Out of memory" = {
      expr    = trimspace(file("${path.module}/queries/oom-kills.promql"))
      above   = 0
      for     = "0m"
      summary = "{{ $labels.instance }}에서 커널이 프로세스를 죽였습니다. 최근 10분 동안 {{ printf \"%.0f\" $values.A.Value }}번입니다."
    }
    "Container near its memory limit" = {
      expr    = trimspace(file("${path.module}/queries/container-memory-share.promql"))
      above   = 90
      for     = "10m"
      summary = "{{ $labels.name }}이 제 메모리 상한의 {{ printf \"%.0f\" $values.A.Value }}%를 쓰고 있습니다."
    }
  }
}

resource "grafana_rule_group" "memory" {
  name             = "memory"
  folder_uid       = grafana_folder.hosts.uid
  interval_seconds = 60

  dynamic "rule" {
    for_each = local.memory_rules

    content {
      name = rule.key
      for  = rule.value.for

      condition      = "B"
      no_data_state  = "OK"
      exec_err_state = "OK"

      annotations = {
        summary = rule.value.summary
      }

      data {
        ref_id         = "A"
        datasource_uid = data.grafana_data_source.prometheus.uid
        relative_time_range {
          from = 600
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
          conditions = [{ evaluator = { type = "gt", params = [rule.value.above] } }]
        })
      }
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
  explore_exprs = {
    status   = trimspace(file("${path.module}/queries/explore-status.logql"))
    refusals = trimspace(file("${path.module}/queries/explore-refusals.logql"))
  }

  explore_urls = {
    for name, expr in local.explore_exprs :
    name => "https://femiwiki.grafana.net/explore?panes=${urlencode(jsonencode({
      a = {
        datasource = "grafanacloud-logs"
        queries = [{
          datasource = { uid = "grafanacloud-logs" }
          expr       = expr
          queryType  = "range"
          refId      = "A"
        }]
        range = { from = "now-3h", to = "now" }
      }
    }))}&schemaVersion=1"
  }

  successful_responses = trimspace(file("${path.module}/queries/site-down.logql"))
  server_errors        = trimspace(file("${path.module}/queries/server-errors.logql"))
  all_responses        = trimspace(file("${path.module}/queries/all-responses.logql"))
  refused_readers      = trimspace(file("${path.module}/queries/refused-readers.logql"))

  fastcgi_rules = {
    "Requests waiting for a worker" = {
      expr    = trimspace(file("${path.module}/queries/listen-queue.promql"))
      above   = 0
      for     = "5m"
      summary = "요청이 5분 넘게 php-fpm 앞에 줄 서 있습니다. 워커가 모자라면 `phpfpm_max_children_reached`가 함께 오르고, 메모리가 모자라면 `node_memory_MemAvailable_bytes`가 떨어집니다."
    }
  }
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
      summary          = "최근 5분 동안 정상 응답이 {{ printf \"%.0f\" $values.A.Value }}건입니다."
      logs             = local.explore_urls.status
      __dashboardUid__ = grafana_dashboard.this["availability"].uid
      __panelId__      = "1"
    }

    data {
      ref_id         = "A"
      datasource_uid = data.grafana_data_source.loki.uid
      query_type     = "instant"
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

  rule {
    name = "Server errors"
    for  = "5m"

    condition      = "D"
    no_data_state  = "OK"
    exec_err_state = "OK"

    annotations = {
      summary          = "최근 5분 동안 응답의 {{ printf \"%.0f\" $values.C.Value }}%가 5xx입니다. 5xx는 {{ printf \"%.0f\" $values.A.Value }}건입니다."
      logs             = local.explore_urls.status
      __dashboardUid__ = grafana_dashboard.this["availability"].uid
      __panelId__      = "1"
    }

    data {
      ref_id         = "A"
      datasource_uid = data.grafana_data_source.loki.uid
      query_type     = "instant"
      relative_time_range {
        from = 300
        to   = 0
      }
      model = jsonencode({
        refId     = "A"
        expr      = local.server_errors
        queryType = "instant"
        instant   = true
        range     = false
      })
    }

    data {
      ref_id         = "B"
      datasource_uid = data.grafana_data_source.loki.uid
      query_type     = "instant"
      relative_time_range {
        from = 300
        to   = 0
      }
      model = jsonencode({
        refId     = "B"
        expr      = local.all_responses
        queryType = "instant"
        instant   = true
        range     = false
      })
    }

    data {
      ref_id         = "C"
      datasource_uid = "__expr__"
      relative_time_range {
        from = 0
        to   = 0
      }
      model = jsonencode({
        refId      = "C"
        type       = "math"
        expression = "100 * $A / $B"
      })
    }

    data {
      ref_id         = "D"
      datasource_uid = "__expr__"
      relative_time_range {
        from = 0
        to   = 0
      }
      model = jsonencode({
        refId      = "D"
        type       = "math"
        expression = "($C > 10) && ($A > 50)"
      })
    }
  }

  rule {
    name = "Readers refused"
    for  = "30m"

    condition      = "B"
    no_data_state  = "OK"
    exec_err_state = "OK"

    annotations = {
      summary = "최근 5분 동안 로그인하지 않은 독자의 요청 {{ printf \"%.0f\" $values.A.Value }}건이 429로 거절됐습니다."
      logs    = local.explore_urls.refusals
    }

    data {
      ref_id         = "A"
      datasource_uid = data.grafana_data_source.loki.uid
      query_type     = "instant"
      relative_time_range {
        from = 300
        to   = 0
      }
      model = jsonencode({
        refId     = "A"
        expr      = local.refused_readers
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
        conditions = [{ evaluator = { type = "gt", params = [0] } }]
      })
    }
  }
}

resource "grafana_rule_group" "femiwiki_fastcgi" {
  name             = "fastcgi"
  folder_uid       = data.grafana_folder.femiwiki.uid
  interval_seconds = 60

  dynamic "rule" {
    for_each = local.fastcgi_rules

    content {
      name = rule.key
      for  = rule.value.for

      condition      = "B"
      no_data_state  = "OK"
      exec_err_state = "OK"

      annotations = {
        summary = rule.value.summary
        # A resolved notification carries the value it resolved at, which for a
        # queue is always zero, so the reading goes beside the text rather than in it
        queue = "{{ printf \"%.0f\" $values.A.Value }}"
      }

      data {
        ref_id         = "A"
        datasource_uid = data.grafana_data_source.prometheus.uid
        relative_time_range {
          from = 600
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
          conditions = [{ evaluator = { type = "gt", params = [rule.value.above] } }]
        })
      }
    }
  }
}

resource "grafana_contact_point" "discord" {
  for_each = local.discord_contact_points

  name = "Discord ${each.key}"

  discord {
    url                  = var.discord_webhook_url
    use_discord_username = false

    title = trimspace(file("${path.module}/templates/${each.value}"))
    message = trimspace(replace(
      file("${path.module}/templates/discord-message.gotmpl"),
      "__MENTION_ROLE__",
      var.discord_mention_role_id,
    ))
  }
}

resource "grafana_contact_point" "discord_default" {
  name               = "Discord"
  disable_provenance = true

  discord {
    url                  = var.discord_webhook_url
    use_discord_username = false

    title   = trimspace(file("${path.module}/templates/alert-title.gotmpl"))
    message = trimspace(file("${path.module}/templates/alert-message.gotmpl"))
  }
}
