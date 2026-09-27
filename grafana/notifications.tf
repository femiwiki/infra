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

  # Public, and ahead of the Discord branches with continue so an alert reaches
  # both. Only critical goes here: the rest name hosts and cache internals that
  # tell a reader nothing. A timeline stacks a repeat rather than raising it back
  # into view, so the repeat is a day rather than the pager's half hour.
  policy {
    matcher {
      label = "severity"
      match = "="
      value = "critical"
    }

    contact_point   = grafana_contact_point.mastodon.name
    continue        = true
    group_by        = ["alertname"]
    group_wait      = "30s"
    group_interval  = "5m"
    repeat_interval = "24h"
  }

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
