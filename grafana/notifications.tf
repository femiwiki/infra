locals {
  discord_contact_points = {
    critical = { title = "critical-title.gotmpl", message = "discord-message.gotmpl" }
    warning  = { title = "warning-title.gotmpl", message = "alert-message.gotmpl" }
  }

  # Keyed by the rules' impact label: who feels it decides where it goes.
  impact_routes = {
    readers   = { contact_point = grafana_contact_point.discord["critical"].name, group_interval = "5m", repeat_interval = "30m" }
    writers   = { contact_point = grafana_contact_point.discord["warning"].name, group_interval = "5m", repeat_interval = "12h" }
    operators = { contact_point = grafana_contact_point.github.name, group_interval = "1h", repeat_interval = "1w" }
    none      = { contact_point = grafana_contact_point.discord["warning"].name, group_interval = "5m", repeat_interval = "12h" }
  }
}

resource "grafana_notification_policy" "root" {
  contact_point   = grafana_contact_point.discord_default.name
  group_by        = ["alertname", "instance"]
  group_wait      = "30s"
  group_interval  = "5m"
  repeat_interval = "4h"

  policy {
    matcher {
      label = "impact"
      match = "=~"
      value = "readers|writers"
    }

    contact_point   = grafana_contact_point.mastodon.name
    continue        = true
    group_by        = ["alertname"]
    group_wait      = "30s"
    group_interval  = "5m"
    repeat_interval = "1d"
  }

  dynamic "policy" {
    for_each = local.impact_routes

    content {
      matcher {
        label = "impact"
        match = "="
        value = policy.key
      }

      contact_point   = policy.value.contact_point
      group_by        = ["alertname"]
      group_wait      = "30s"
      group_interval  = policy.value.group_interval
      repeat_interval = policy.value.repeat_interval
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

resource "grafana_contact_point" "mastodon" {
  name = "Mastodon"

  webhook {
    url                       = "https://mastodon.social/api/v1/statuses"
    authorization_scheme      = "Bearer"
    authorization_credentials = var.mastodon_token

    payload {
      template = trimspace(file("${path.module}/templates/mastodon-payload.gotmpl"))
    }
  }
}

resource "grafana_contact_point" "github" {
  name = "GitHub issue"

  # The grafana-github function in femiwiki/lambda, which opens and comments on issues in femiwiki/infra.
  webhook {
    url                       = "https://5jd5wc535aduc32dvlpdg5zyq40fspgt.lambda-url.ap-northeast-2.on.aws/"
    authorization_scheme      = "Bearer"
    authorization_credentials = var.alerts_webhook_token
  }
}
