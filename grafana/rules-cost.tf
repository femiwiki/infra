resource "grafana_rule_group" "cost" {
  name             = "cost"
  folder_uid       = grafana_folder.hosts.uid
  interval_seconds = 300

  rule {
    name = "CPU surplus credits are being charged"
    for  = "1h"

    condition      = "D"
    no_data_state  = "OK"
    exec_err_state = "OK"

    labels = {
      impact   = "operators"
      severity = "warning"
    }

    annotations = {
      summary = "{{ $labels.instance }}의 CPU가 한 시간 넘게 평균 {{ printf \"%.0f\" $values.A.Value }}%입니다. t4g.small 기준선 20%를 넘는 만큼 CPU 크레딧을 써서 시간당 약 {{ printf \"%.0f\" $values.B.Value }} 크레딧, 하루로 치면 약 $${{ printf \"%.2f\" $values.C.Value }}입니다. 크레딧 잔액이 0인 동안은 이 금액이 그대로 청구됩니다. 평소 웹 호스트는 25~33%, 시간당 약 10 크레딧입니다. 늘어난 요청이 어디서 오는지 Caddy 로그에서 봅니다."
    }

    data {
      ref_id         = "A"
      datasource_uid = data.grafana_data_source.prometheus.uid
      relative_time_range {
        from = 3600
        to   = 0
      }
      model = jsonencode({
        refId   = "A"
        expr    = trimspace(file("${path.module}/queries/node-cpu-hour.promql"))
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
        type       = "math"
        expression = "($A - 20) * 1.2"
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
        expression = "$B * 24 / 60 * 0.04"
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
        type       = "threshold"
        expression = "A"
        conditions = [{ evaluator = { type = "gt", params = [35] } }]
      })
    }
  }
}
