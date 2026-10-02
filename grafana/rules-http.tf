locals {
  explore_exprs = {
    status = trimspace(file("${path.module}/queries/explore-status.logql"))
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
  dump_failed          = trimspace(file("${path.module}/queries/dump-failed.logql"))
  dump_published       = trimspace(file("${path.module}/queries/dump-published.logql"))
  dump_due             = trimspace(file("${path.module}/queries/dump-due.promql"))
  successful_responses = trimspace(file("${path.module}/queries/site-down.logql"))
  server_errors        = trimspace(file("${path.module}/queries/server-errors.logql"))
  all_responses        = trimspace(file("${path.module}/queries/all-responses.logql"))
  busiest_network      = trimspace(file("${path.module}/queries/concentrated-refusals.logql"))
  history_refused      = trimspace(file("${path.module}/queries/history-refused.logql"))
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
      impact   = "readers"
      severity = "critical"
    }

    annotations = {
      summary          = "최근 5분 동안 정상 응답이 {{ printf \"%.0f\" $values.A.Value }}건입니다."
      logs             = local.explore_urls.status
      __dashboardUid__ = grafana_dashboard.availability.uid
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

    labels = {
      impact   = "readers"
      severity = "critical"
    }

    annotations = {
      summary          = "최근 5분 동안 응답의 {{ printf \"%.0f\" $values.C.Value }}%가 5xx입니다. 5xx는 {{ printf \"%.0f\" $values.A.Value }}건입니다."
      logs             = local.explore_urls.status
      __dashboardUid__ = grafana_dashboard.availability.uid
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
    name            = "One network is being refused far more than the rest"
    for             = "1h"
    keep_firing_for = "1h"

    condition      = "B"
    no_data_state  = "OK"
    exec_err_state = "OK"

    labels = {
      impact   = "none"
      severity = "warning"
    }

    annotations = {
      summary = "{{ $labels.net }} 한 망에서만 최근 한 시간에 {{ printf \"%.0f\" $values.A.Value }}건이 거절됐습니다. 퍼져 있는 크롤은 한 망에서 백 건을 넘지 않으니, 이건 한 곳이 긁고 있다는 뜻입니다. 그 대역을 막을지 정하면 됩니다."
      logs    = grafana_dashboard.this["scrapes"].url
    }

    data {
      ref_id         = "A"
      datasource_uid = data.grafana_data_source.loki.uid
      query_type     = "instant"
      relative_time_range {
        from = 3600
        to   = 0
      }
      model = jsonencode({
        refId     = "A"
        expr      = local.busiest_network
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
        conditions = [{ evaluator = { type = "gt", params = [400] } }]
      })
    }
  }

  rule {
    name            = "Page history refused by its own budget"
    for             = "1h"
    keep_firing_for = "1h"

    condition      = "B"
    no_data_state  = "OK"
    exec_err_state = "OK"

    labels = {
      impact   = "none"
      severity = "warning"
    }

    annotations = {
      summary = "역사와 정보 요청이 자기 예산에서 거절되고 있습니다. 최근 한 시간에 {{ printf \"%.0f\" $values.A.Value }}건입니다. 거절이 한 망에서만 나오면 그 망이 긁고 있는 것이고, 여러 망에서 나오면 `FW_HISTORY_EVENTS`가 낮은 것입니다."
      logs    = grafana_dashboard.this["scrapes"].url
    }

    data {
      ref_id         = "A"
      datasource_uid = data.grafana_data_source.loki.uid
      query_type     = "instant"
      relative_time_range {
        from = 3600
        to   = 0
      }
      model = jsonencode({
        refId     = "A"
        expr      = local.history_refused
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
        conditions = [{ evaluator = { type = "gt", params = [10] } }]
      })
    }
  }

  rule {
    name = "The wiki is read-only"
    for  = "0m"

    condition      = "C"
    no_data_state  = "OK"
    exec_err_state = "OK"

    labels = {
      impact   = "writers"
      severity = "warning"
    }

    annotations = {
      summary = "지금 페미위키를 편집할 수 없으며 읽기만 가능합니다."
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
        url           = "https://femiwiki.com/api.php?action=query&meta=siteinfo&siprop=general&format=json&formatversion=2"
        url_options   = { method = "GET" }
        root_selector = "query.general.{\"readonly\": readonly ? 1 : 0}"
        json_options  = { root_is_not_array = true }
        columns       = [{ selector = "readonly", text = "readonly", type = "number" }]
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
        conditions = [{ evaluator = { type = "gt", params = [0] } }]
      })
    }
  }
}
