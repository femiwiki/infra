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

  sitemap_rebuilt      = trimspace(file("${path.module}/queries/sitemap-rebuilt.logql"))
  successful_responses = trimspace(file("${path.module}/queries/site-down.logql"))
  server_errors        = trimspace(file("${path.module}/queries/server-errors.logql"))
  all_responses        = trimspace(file("${path.module}/queries/all-responses.logql"))
  refused_readers      = trimspace(file("${path.module}/queries/refused-readers.logql"))
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
