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

  rule {
    name = "A fixed-performance instance would be cheaper"
    for  = "1h"

    condition      = "C"
    no_data_state  = "OK"
    exec_err_state = "OK"

    labels = {
      impact   = "operators"
      severity = "warning"
    }

    annotations = {
      summary = "{{ $labels.instance }}의 최근 7일 평균 CPU가 {{ printf \"%.1f\" $values.A.Value }}%로, 하루 약 {{ printf \"%.0f\" $values.B.Value }} CPU 크레딧을 씁니다. 45%(하루 1,296 크레딧)를 넘으면 t4g.small unlimited보다 c7g.medium이 쌉니다. t4g.small은 시간당 0.0208달러에 기준선(2 vCPU의 20%, 시간당 24 크레딧)을 넘는 vCPU-시간마다 0.04달러를 더 내고, c7g.medium은 시간당 0.0408달러입니다. 차액 0.02달러는 초과 0.5 vCPU-시간, 곧 시간당 30 크레딧이므로 기준선과 합쳐 시간당 54 크레딧, 2 vCPU의 45%에서 두 요금이 같아집니다. 이 값은 호스트 안에서 잰 CPU라 AWS의 CPUCreditUsage보다 1%p쯤 낮게 나오므로 44%에서 알립니다. 이 호스트(aws/web-seoul.tf 또는 aws/database-seoul.tf)의 인스턴스 타입을 바꿀지 검토합니다. c7g.medium은 vCPU가 하나라 같은 부하에서 사용률이 약 90%가 됩니다."
    }

    data {
      ref_id         = "A"
      datasource_uid = data.grafana_data_source.prometheus.uid
      relative_time_range {
        from = 604800
        to   = 0
      }
      model = jsonencode({
        refId   = "A"
        expr    = trimspace(file("${path.module}/queries/node-cpu-week.promql"))
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
        expression = "$A * 1.2 * 24"
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
        expression = "A"
        conditions = [{ evaluator = { type = "gt", params = [44] } }]
      })
    }
  }

  rule {
    name = "Spot overflow capacity would pay for itself"
    for  = "1h"

    condition      = "B"
    no_data_state  = "OK"
    exec_err_state = "OK"

    labels = {
      impact   = "operators"
      severity = "warning"
    }

    annotations = {
      summary = "웹 호스트의 최근 7일 평균 CPU가 {{ printf \"%.1f\" $values.A.Value }}%입니다. 32%를 넘으면 php-fpm 스팟 증설(femiwiki/infra#1139)이 경보·AMI 같은 고정비를 넘게 아낄 수 있습니다. 32%는 #1139의 스케일아웃 기준이라, 그 아래에서는 스팟이 거의 켜지지 않습니다. 평균 36%였던 2026-09-29~10-03 부하에서 아끼는 돈은 한 달 약 1.80달러였습니다. 이 값은 호스트 안에서 잰 CPU라 AWS보다 1%p쯤 낮게 나오므로 31%에서 알립니다. #1139을 만들지 다시 검토합니다."
    }

    data {
      ref_id         = "A"
      datasource_uid = data.grafana_data_source.prometheus.uid
      relative_time_range {
        from = 604800
        to   = 0
      }
      model = jsonencode({
        refId   = "A"
        expr    = trimspace(file("${path.module}/queries/web-cpu-week.promql"))
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
        conditions = [{ evaluator = { type = "gt", params = [31] } }]
      })
    }
  }
}
