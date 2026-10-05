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
      impact   = "operators"
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
      impact   = "operators"
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
      impact   = "operators"
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

# The two dump rules read a day or two of every fastcgi log, which costs Loki's
# query allowance on each evaluation; an hour late is fine for a twice-yearly job.
resource "grafana_rule_group" "femiwiki_dumps" {
  name             = "dumps"
  folder_uid       = data.grafana_folder.femiwiki.uid
  interval_seconds = 3600

  rule {
    name = "The public dump failed to upload"
    for  = "0s"

    condition      = "B"
    no_data_state  = "OK"
    exec_err_state = "OK"

    labels = {
      impact   = "operators"
      severity = "warning"
    }

    annotations = {
      summary = "`publish-dump`가 공개 덤프를 Internet Archive에 올리지 못했습니다. fastcgi 컨테이너의 `/var/log/cron.log`에 실패한 단계가 남아 있습니다. 덤프 파일은 지워졌으니 원인을 고친 뒤 컨테이너에서 `publish-dump`를 다시 돌립니다."
    }

    data {
      ref_id         = "A"
      datasource_uid = data.grafana_data_source.loki.uid
      query_type     = "instant"
      # Keeps the alert firing for a day after the failure.
      relative_time_range {
        from = 86400
        to   = 0
      }
      model = jsonencode({
        refId     = "A"
        expr      = local.dump_failed
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

  rule {
    name = "The public dump was not published"
    for  = "0s"

    condition      = "C"
    no_data_state  = "OK"
    exec_err_state = "OK"

    labels = {
      impact   = "operators"
      severity = "warning"
    }

    annotations = {
      summary = "1월 1일·7월 1일 18:00 UTC에 시작한 공개 덤프가 18시간이 지나도록 끝났다는 줄을 남기지 않았습니다. cron이 돌지 않았거나, 실패 줄을 남기기 전에 죽었거나, 아직 덤프 중입니다. fastcgi 컨테이너의 `/var/log/cron.log`를 봅니다."
    }

    data {
      ref_id         = "A"
      datasource_uid = data.grafana_data_source.loki.uid
      query_type     = "instant"
      # Reaches back past the 18:00 start from the end of the next day.
      relative_time_range {
        from = 172800
        to   = 0
      }
      model = jsonencode({
        refId     = "A"
        expr      = local.dump_published
        queryType = "instant"
        instant   = true
        range     = false
      })
    }

    # 1 from 18 hours after the Jan 1 and Jul 1 run until the day ends, else 0.
    data {
      ref_id         = "B"
      datasource_uid = data.grafana_data_source.prometheus.uid
      relative_time_range {
        from = 600
        to   = 0
      }
      model = jsonencode({
        refId   = "B"
        expr    = local.dump_due
        instant = true
        range   = false
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
        expression = "($B > 0) && ($A < 1)"
      })
    }
  }
}
