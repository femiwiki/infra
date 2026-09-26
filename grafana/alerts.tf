data "grafana_data_source" "prometheus" {
  name = "grafanacloud-femiwiki-prom"
}

data "grafana_data_source" "loki" {
  name = "grafanacloud-femiwiki-logs"
}

data "grafana_data_source" "usage" {
  name = "grafanacloud-usage"
}

data "grafana_data_source" "infinity" {
  name = "grafanacloud-infinity"
}

locals {
  discord_contact_points = {
    critical = { title = "site-down-title.gotmpl", message = "discord-message.gotmpl" }
    warning  = { title = "warning-title.gotmpl", message = "alert-message.gotmpl" }
  }

  discord_routes = {
    critical = "30m"
    warning  = "12h"
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
}

locals {
  retiring_instance     = "femiwiki"
  retiring_max_requests = 60

  rule_defaults = {
    datasource     = data.grafana_data_source.prometheus.uid
    window         = 600
    op             = "gt"
    for            = "5m"
    no_data_state  = "OK"
    exec_err_state = "OK"
  }

  raw_threshold_groups = {
    memory = {
      folder   = grafana_folder.hosts.uid
      interval = 60
      rules = [
        {
          name        = "Container near its memory limit"
          expr        = trimspace(file("${path.module}/queries/container-memory-share.promql"))
          threshold   = 95
          for         = "30m"
          labels      = { severity = "warning" }
          annotations = { summary = "{{ $labels.instance }}의 {{ $labels.name }}이 제 메모리 상한의 {{ printf \"%.0f\" $values.A.Value }}%를 쓰고 있습니다." }
        },
        {
          name        = "Out of memory"
          expr        = trimspace(file("${path.module}/queries/oom-kills.promql"))
          threshold   = 0
          for         = "0m"
          labels      = {}
          annotations = { summary = "{{ $labels.instance }}에서 커널이 프로세스를 죽였습니다. 최근 10분 동안 {{ printf \"%.0f\" $values.A.Value }}번입니다." }
        },
      ]
    }

    hosts = {
      folder   = grafana_folder.hosts.uid
      interval = 60
      rules = [
        {
          name           = "Disk almost full"
          expr           = "100 * node_filesystem_avail_bytes{job=\"integrations/node_exporter\", mountpoint=\"/\"} / node_filesystem_size_bytes{job=\"integrations/node_exporter\", mountpoint=\"/\"}"
          op             = "lt"
          threshold      = 10
          window         = 300
          for            = "10m"
          no_data_state  = "Alerting"
          exec_err_state = "Alerting"
          labels         = {}
          annotations    = { summary = "{{ $labels.instance }}: {{ printf \"%.0f\" $values.A.Value }}% of / left" }
        },
        {
          name        = "A target stopped reporting"
          expr        = trimspace(file("${path.module}/queries/vanished-targets.promql"))
          threshold   = 0
          for         = "30m"
          labels      = { severity = "warning" }
          annotations = { summary = "{{ $labels.instance }}의 {{ $labels.job }}이 30분 넘게 지표를 보내지 않습니다. 두 시간 안에는 보내고 있었습니다. 호스트를 내린 것이면 두 시간 뒤 스스로 해소되고, 아니면 그 호스트의 Alloy를 봐야 합니다." }
        },
        {
          name           = "Memory almost gone"
          expr           = "node_memory_MemAvailable_bytes{job=\"integrations/node_exporter\"} / 1024 / 1024"
          op             = "lt"
          threshold      = 100
          window         = 300
          for            = "15m"
          no_data_state  = "NoData"
          exec_err_state = "Alerting"
          labels         = {}
          annotations    = { summary = "{{ $labels.instance }}: {{ printf \"%.0f\" $values.A.Value }} MB available" }
        },
      ]
    }

    fastcgi = {
      folder   = data.grafana_folder.femiwiki.uid
      interval = 60
      rules = [
        {
          name      = "Interned strings buffer almost full"
          expr      = trimspace(file("${path.module}/queries/opcache-interned-strings.promql"))
          threshold = 95
          for       = "15m"
          labels    = { severity = "warning" }
          annotations = {
            summary = "{{ $labels.instance }}의 opcache에서 interned strings 버퍼가 {{ printf \"%.0f\" $values.A.Value }}% 찼습니다. 다 차면 PHP가 인터닝을 멈춰서 워커마다 클래스와 함수 이름을 따로 들고 갑니다. `PHP_OPCACHE_INTERNED_STRINGS_BUFFER`를 올리면 이미지 빌드 없이 적용됩니다."
          }
        },
        {
          name      = "Opcache restarted out of memory"
          expr      = trimspace(file("${path.module}/queries/opcache-oom-restarts.promql"))
          threshold = 0
          for       = "0m"
          labels    = { severity = "warning" }
          annotations = {
            summary = "{{ $labels.instance }}의 opcache가 메모리가 모자라 최근 10분 동안 {{ printf \"%.0f\" $values.A.Value }}번 재시작했습니다. 재시작 직후에는 모든 요청이 컴파일을 다시 합니다. `PHP_OPCACHE_MEMORY_CONSUMPTION`를 올리면 이미지 빌드 없이 적용됩니다."
          }
        },
        {
          name      = "Requests waiting for a worker"
          expr      = trimspace(file("${path.module}/queries/listen-queue.promql"))
          threshold = 0
          labels    = {}
          annotations = {
            summary = "{{ $labels.instance }}에서 요청이 5분 넘게 php-fpm 앞에 줄 서 있습니다. 워커가 모자라면 `phpfpm_max_children_reached`가 함께 오르고, 메모리가 모자라면 `node_memory_MemAvailable_bytes`가 떨어집니다."
            # A resolved notification carries the value it resolved at, which for a
            # queue is always zero, so the reading goes beside the text rather than in it
            queue = "{{ printf \"%.0f\" $values.A.Value }}"
          }
        },
        {
          name      = "Script cache table full"
          expr      = trimspace(file("${path.module}/queries/opcache-table-share.promql"))
          threshold = 99
          for       = "15m"
          labels    = { severity = "warning" }
          annotations = {
            summary = "{{ $labels.instance }}의 opcache가 스크립트를 담는 표의 {{ printf \"%.0f\" $values.A.Value }}%를 썼습니다. 다 차면 새 스크립트는 캐시에 들어가지 못해 요청마다 다시 컴파일됩니다. `PHP_OPCACHE_MAX_ACCELERATED_FILES`를 올리면 이미지 빌드 없이 적용됩니다."
          }
        },
        {
          name      = "Script cache memory almost gone"
          expr      = trimspace(file("${path.module}/queries/opcache-free-memory.promql"))
          op        = "lt"
          threshold = 8
          for       = "15m"
          labels    = { severity = "warning" }
          annotations = {
            summary = "{{ $labels.instance }}의 opcache에 스크립트 메모리가 {{ printf \"%.0f\" $values.A.Value }} MB 남았습니다. 다 쓰면 opcache가 재시작하면서 캐시를 비웁니다. `PHP_OPCACHE_MEMORY_CONSUMPTION`를 올리면 이미지 빌드 없이 적용됩니다."
          }
        },
        {
          name      = "Opcache restarted out of table slots"
          expr      = trimspace(file("${path.module}/queries/opcache-hash-restarts.promql"))
          threshold = 0
          for       = "0m"
          labels    = { severity = "warning" }
          annotations = {
            summary = "{{ $labels.instance }}의 opcache가 표가 모자라 최근 10분 동안 {{ printf \"%.0f\" $values.A.Value }}번 재시작했습니다. 재시작 직후에는 모든 요청이 컴파일을 다시 합니다. `PHP_OPCACHE_MAX_ACCELERATED_FILES`를 올리면 이미지 빌드 없이 적용됩니다."
          }
        },
      ]
    }

    retiring = {
      folder   = grafana_folder.hosts.uid
      interval = 300
      rules = [
        {
          name      = "Retiring host has drained"
          expr      = replace(trimspace(file("${path.module}/queries/retiring-host-requests.promql")), "__INSTANCE__", local.retiring_instance)
          op        = "lt"
          threshold = local.retiring_max_requests
          window    = 3600
          for       = "1h"
          labels    = { severity = "warning" }
          annotations = {
            summary = "{{ $labels.instance }}이 최근 1시간 동안 {{ printf \"%.0f\" $values.A.Value }}건만 받았습니다. 이 주소를 아직 들고 있는 리졸버가 사실상 없다는 뜻이므로 이 상자는 은퇴시켜도 됩니다. 상자가 보고를 멈추면 이 규칙은 울리지 않으니, 조용한 것과 멈춘 것을 혼동하지 않습니다."
          }
        },
      ]
    }

    logs = {
      folder   = grafana_folder.hosts.uid
      interval = 300
      rules = [
        {
          name       = "Logs are arriving faster than the plan allows"
          datasource = data.grafana_data_source.usage.uid
          expr       = trimspace(file("${path.module}/queries/log-volume-projection.promql"))
          threshold  = 100
          window     = 21600
          for        = "30m"
          labels     = { severity = "warning" }
          annotations = {
            summary = "최근 6시간 속도가 이어지면 로그가 한 달에 {{ printf \"%.0f\" $values.A.Value }} GB입니다. 무료 플랜 포함량은 50 GB이고, 넘기면 수집이 끊겨 이 쪽 감시가 통째로 조용해집니다. 로그의 92%는 Caddy 접근 로그입니다."
          }
        },
      ]
    }
  }

  threshold_groups = {
    for group, v in local.raw_threshold_groups : group => {
      folder   = v.folder
      interval = v.interval
      rules = [
        for r in v.rules : merge(local.rule_defaults, r, {
          labels      = tomap(r.labels)
          annotations = tomap(r.annotations)
        })
      ]
    }
  }
}

resource "grafana_rule_group" "threshold" {
  for_each = local.threshold_groups

  name             = each.key
  folder_uid       = each.value.folder
  interval_seconds = each.value.interval

  dynamic "rule" {
    for_each = each.value.rules

    content {
      name = rule.value.name
      for  = rule.value.for

      condition      = "B"
      no_data_state  = rule.value.no_data_state
      exec_err_state = rule.value.exec_err_state

      labels      = rule.value.labels
      annotations = rule.value.annotations

      data {
        ref_id         = "A"
        datasource_uid = rule.value.datasource
        relative_time_range {
          from = rule.value.window
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
          conditions = [{ evaluator = { type = rule.value.op, params = [rule.value.threshold] } }]
        })
      }
    }
  }
}

moved {
  from = grafana_rule_group.memory
  to   = grafana_rule_group.threshold["memory"]
}

moved {
  from = grafana_rule_group.hosts
  to   = grafana_rule_group.threshold["hosts"]
}

moved {
  from = grafana_rule_group.femiwiki_fastcgi
  to   = grafana_rule_group.threshold["fastcgi"]
}

moved {
  from = grafana_rule_group.logs
  to   = grafana_rule_group.threshold["logs"]
}

resource "grafana_rule_group" "femiwiki_jobs" {
  name             = "jobs"
  folder_uid       = data.grafana_folder.femiwiki.uid
  interval_seconds = 300

  rule {
    name = "The job queue is not draining"
    for  = "1h"

    condition      = "C"
    no_data_state  = "OK"
    exec_err_state = "OK"

    labels = {
      severity = "warning"
    }

    annotations = {
      summary = "작업 큐에 {{ printf \"%.0f\" $values.B.Value }}건이 한 시간 넘게 쌓여 있습니다. 위키는 멀쩡히 응답하면서도 이렇게 되고, 대개 cron이 데이터베이스에 닿지 못한다는 뜻입니다. 컨테이너에서 `run-jobs`가 도는지 봅니다."
    }

    data {
      ref_id         = "A"
      datasource_uid = data.grafana_data_source.infinity.uid
      relative_time_range {
        from = 600
        to   = 0
      }
      model = jsonencode({
        refId         = "A"
        type          = "json"
        source        = "url"
        format        = "table"
        parser        = "backend"
        url           = "https://femiwiki.com/api.php?action=query&meta=siteinfo&siprop=statistics&format=json"
        url_options   = { method = "GET" }
        root_selector = "query.statistics"
        json_options  = { root_is_not_array = true }
        columns       = [{ selector = "jobs", text = "jobs", type = "number" }]
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
        type       = "reduce"
        reducer    = "last"
        expression = "A"
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
        type       = "threshold"
        expression = "B"
        conditions = [{ evaluator = { type = "gt", params = [1000] } }]
      })
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
    name            = "Logged-out requests refused"
    for             = "4h"
    keep_firing_for = "1h"

    condition      = "B"
    no_data_state  = "OK"
    exec_err_state = "OK"

    labels = {
      severity = "warning"
    }

    annotations = {
      summary = "로그인하지 않은 요청이 네 시간 내내 429로 거절되고 있습니다. 최근 한 시간에만 {{ printf \"%.0f\" $values.A.Value }}건입니다. 짧은 스크레이프는 예산이 알아서 막으므로 이 알림은 그것이 하루 종일 이어질 때만 옵니다. `docker/`의 `FW_EXPENSIVE_EVENTS`를 다시 볼 때라는 뜻입니다."
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

resource "grafana_contact_point" "discord" {
  for_each = local.discord_contact_points

  name = "Discord ${each.key}"

  discord {
    url                  = var.discord_webhook_url
    use_discord_username = false

    title = trimspace(file("${path.module}/templates/${each.value.title}"))
    message = trimspace(replace(
      file("${path.module}/templates/${each.value.message}"),
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
