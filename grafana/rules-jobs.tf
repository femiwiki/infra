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

  rule {
    name = "The sitemap has not been rebuilt"
    for  = "30m"

    condition      = "B"
    no_data_state  = "OK"
    exec_err_state = "OK"

    labels = {
      severity = "warning"
    }

    annotations = {
      summary = "사이트맵이 여덟 시간 넘게 다시 만들어지지 않았습니다. `generate-sitemap`은 네 시간마다 돌고 끝나면 로그에 한 줄을 남기는데, 그 줄이 두 번 연속 없습니다. cron이 데이터베이스에 닿지 못하면 이렇게 되고, 그동안 robots.txt는 갱신을 멈춘 사이트맵을 계속 가리킵니다."
    }

    data {
      ref_id         = "A"
      datasource_uid = data.grafana_data_source.loki.uid
      query_type     = "instant"
      relative_time_range {
        from = 28800
        to   = 0
      }
      model = jsonencode({
        refId     = "A"
        expr      = local.sitemap_rebuilt
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
        conditions = [{ evaluator = { type = "lt", params = [1] } }]
      })
    }
  }

  rule {
    name = "The sitemap cannot be read"
    for  = "30m"

    condition      = "C"
    no_data_state  = "Alerting"
    exec_err_state = "Alerting"

    labels = {
      severity = "warning"
    }

    annotations = {
      summary = "검색엔진이 읽는 방식 그대로 사이트맵 색인을 가져오는 데 실패했습니다. robots.txt가 가리키는 주소가 XML이 아니거나 목록이 비어 있다는 뜻입니다. 작업이 파일을 만들어도 그 경로를 내주지 않으면 이렇게 됩니다."
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
        type          = "xml"
        source        = "url"
        format        = "table"
        parser        = "backend"
        url           = "https://femiwiki.com/sitemap/sitemap-index-femiwiki.xml"
        url_options   = { method = "GET" }
        root_selector = "sitemapindex.sitemap"

        columns          = [{ selector = "loc", text = "loc", type = "string" }]
        computed_columns = [{ selector = "1", text = "one", type = "number" }]
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
        reducer    = "sum"
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
        conditions = [{ evaluator = { type = "lt", params = [1] } }]
      })
    }
  }
}
