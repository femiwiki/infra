locals {
  # Secret name => infra vault item title, the value in the item's password.
  # DISCORD_WEBHOOK_URL and MASTODON_TOKEN go once grafana reads the new names (#982).
  infra_secrets = {
    AWS_LOKI_PASSWORD           = "AWS_LOKI_PASSWORD"
    AWS_PROMETHEUS_PASSWORD     = "AWS_PROMETHEUS_PASSWORD"
    AWS_STATE_PASSPHRASE        = "AWS_STATE_PASSPHRASE"
    DISCORD_WEBHOOK_URL         = "GRAFANA_DISCORD_WEBHOOK_URL"
    GRAFANA_DISCORD_WEBHOOK_URL = "GRAFANA_DISCORD_WEBHOOK_URL"
    GRAFANA_MASTODON_TOKEN      = "GRAFANA_MASTODON_TOKEN"
    GRAFANA_PLAN_TOKEN          = "GRAFANA_PLAN_TOKEN"
    HEALTHCHECKSIO_API_KEY      = "HEALTHCHECKSIO_API_KEY"
    MASTODON_TOKEN              = "GRAFANA_MASTODON_TOKEN"
    TOFU_DISCORD_WEBHOOK        = "TOFU_DISCORD_WEBHOOK"
    WIKI_DEPLOY_BOT_PASSWORD    = "WIKI_DEPLOY_BOT_PASSWORD"
  }

  # Read by no plan, so they sit behind the environment's reviewers (#982).
  infra_environment_secrets = {
    GRAFANA_APPLY_TOKEN = { environment = "grafana", item = "GRAFANA_APPLY_TOKEN" }
  }
}

data "onepassword_vault" "infra" {
  name = "infra"
}

data "onepassword_item" "infra" {
  for_each = toset(concat(values(local.infra_secrets), [for s in values(local.infra_environment_secrets) : s.item]))

  vault = data.onepassword_vault.infra.uuid
  title = each.key
}

resource "github_actions_secret" "infra" {
  for_each = local.infra_secrets

  repository  = module.infra.name
  secret_name = each.key
  value       = data.onepassword_item.infra[each.value].password
}

resource "github_actions_environment_secret" "infra" {
  for_each = local.infra_environment_secrets

  repository  = module.infra.name
  environment = github_repository_environment.infra[each.value.environment].environment
  secret_name = each.key
  value       = data.onepassword_item.infra[each.value.item].password
}
