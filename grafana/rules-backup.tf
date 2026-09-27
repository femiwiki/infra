locals {
  backup_uploaded = trimspace(file("${path.module}/queries/backup-uploaded.logql"))
}

resource "grafana_rule_group" "backup" {
  name             = "backup"
  folder_uid       = grafana_folder.hosts.uid
  interval_seconds = 300

  rule {
    name = "The database dump has not reached S3"
    for  = "30m"

    condition      = "B"
    no_data_state  = "Alerting"
    exec_err_state = "Alerting"

    labels = {
      severity = "warning"
    }

    annotations = {
      summary = "26시간 동안 데이터베이스 덤프가 S3에 올라간 기록이 없습니다. 덤프 타이머는 매일 21:00 UTC에 돌고, 성공하면 저널에 업로드 한 줄을 남깁니다. 이 규칙은 `*-backup.service` 유닛의 저널을 보므로, 유닛 이름이 그 모양을 벗어나게 바뀌었다면 백업이 아니라 이 규칙을 고쳐야 합니다. healthchecks.io 쪽과 독립된 두 번째 감시라, 둘 중 하나만 울렸다면 먼저 의심할 곳은 핑이 나가는 길입니다."
    }

    data {
      ref_id         = "A"
      datasource_uid = data.grafana_data_source.loki.uid
      query_type     = "instant"
      relative_time_range {
        from = 93600
        to   = 0
      }
      model = jsonencode({
        refId     = "A"
        expr      = local.backup_uploaded
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
}
