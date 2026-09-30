locals {
  # Secret name => infra vault item title, the value in the item's password.
  infra_secrets = {
    AWS_LOKI_PASSWORD           = "AWS_LOKI_PASSWORD"
    AWS_PROMETHEUS_PASSWORD     = "AWS_PROMETHEUS_PASSWORD"
    AWS_STATE_PASSPHRASE        = "AWS_STATE_PASSPHRASE"
    GRAFANA_DISCORD_WEBHOOK_URL = "GRAFANA_DISCORD_WEBHOOK_URL"
    GRAFANA_MASTODON_TOKEN      = "GRAFANA_MASTODON_TOKEN"
    GRAFANA_PLAN_TOKEN          = "GRAFANA_PLAN_TOKEN"
    HEALTHCHECKSIO_API_KEY      = "HEALTHCHECKSIO_API_KEY"
    TOFU_DISCORD_WEBHOOK        = "TOFU_DISCORD_WEBHOOK"
    WIKI_DEPLOY_BOT_PASSWORD    = "WIKI_DEPLOY_BOT_PASSWORD"
  }

  lambda_secrets = {
    DISCORD_BOT_TOKEN = "LAMBDA_DISCORD_BOT_TOKEN"
    MASTODON_TOKEN    = "LAMBDA_MASTODON_TOKEN"
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
  for_each = toset(concat(values(local.infra_secrets), values(local.lambda_secrets), [for s in values(local.infra_environment_secrets) : s.item]))

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

resource "github_actions_secret" "lambda" {
  for_each = local.lambda_secrets

  repository  = module.lambda.name
  secret_name = each.key
  value       = data.onepassword_item.infra[each.value].password
}
