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
    DISCORD_BOT_TOKEN     = "LAMBDA_DISCORD_BOT_TOKEN"
    DISCORD_WEBHOOK_URL   = "LAMBDA_DISCORD_WEBHOOK_URL"
    MASTODON_TOKEN        = "LAMBDA_MASTODON_TOKEN"
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

data "onepassword_item" "alerts_app_private_key" {
  vault = data.onepassword_vault.infra.uuid
  title = "LAMBDA_ALERTS_APP_PRIVATE_KEY"
}

resource "github_actions_secret" "alerts_app_private_key" {
  repository  = module.lambda.name
  secret_name = "ALERTS_APP_PRIVATE_KEY"
  value       = data.onepassword_item.alerts_app_private_key.note_value
}

# Grafana sends it and the grafana-github Lambda function checks it; nobody types it.
resource "random_password" "alerts_webhook" {
  length  = 48
  special = false
}

resource "github_actions_secret" "alerts_webhook" {
  for_each = {
    GRAFANA_ALERTS_WEBHOOK_TOKEN = module.infra.name
    ALERTS_WEBHOOK_TOKEN         = module.lambda.name
  }

  repository  = each.value
  secret_name = each.key
  value       = random_password.alerts_webhook.result
}

resource "github_repository_environment" "dot_github_gitlab" {
  repository  = module.dot_github.name
  environment = "gitlab"
}

data "onepassword_item" "gitlab_mirror_ssh_key" {
  vault = data.onepassword_vault.infra.uuid
  title = "DOT_GITHUB_GITLAB_MIRROR_SSH_KEY"
}

resource "github_actions_environment_secret" "gitlab_mirror_ssh_key" {
  repository  = module.dot_github.name
  environment = github_repository_environment.dot_github_gitlab.environment
  secret_name = "GITLAB_MIRROR_SSH_KEY"
  value       = data.onepassword_item.gitlab_mirror_ssh_key.note_value
}
