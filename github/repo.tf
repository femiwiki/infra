locals {
  default_repo = {
    # branch_protection
    enforce_admins = false,
    # temporarily disable requiring reviews due to too few development members.
    required_pull_request_reviews = [],
  }
  with_cd = merge(local.default_repo, {
    enforce_admins = true,
  })
  docker = merge(local.default_repo, {
    enforce_admins = true,
  })
  bot = local.with_cd
}

module "infra" {
  source                        = "./modules/github-repository"
  name                          = "infra"
  description                   = ":evergreen_tree: Terraforming Femiwiki Infrastructure"
  enforce_admins                = local.with_cd.enforce_admins
  required_pull_request_reviews = local.with_cd.required_pull_request_reviews
  required_status_checks_strict = true
  required_status_checks_contexts = [
    "docker plan is empty",
    "grafana plan is empty",
    "tflint",
    "shellcheck",
    "rumdl",
    "yamllint",
    "parallel-lint",
    "taplo",
  ]
  topics = [
    "terraform",
  ]
}

module "femiwiki" {
  source                        = "./modules/github-repository"
  name                          = "femiwiki"
  description                   = ":earth_asia: 문서화된 페미위키 기술 정보 및 이슈 트래킹 정보 제공"
  homepage_url                  = "https://femiwiki.com"
  required_pull_request_reviews = local.default_repo.required_pull_request_reviews
  topics = [
    "feminism",
    "wiki",
  ]
  required_status_checks_contexts = ["lint"]
}

module "docker_mediawiki" {
  source                          = "./modules/github-repository"
  name                            = "docker-mediawiki"
  description                     = ":whale: Dockerized Femiwiki's mediawiki server"
  delete_branch_on_merge          = true
  enforce_admins                  = local.docker.enforce_admins
  required_pull_request_reviews   = local.docker.required_pull_request_reviews
  required_status_checks_contexts = ["php-lint", "caddy-fmt", "etc-lint", "hadolint", "shellcheck", "image builds", "title scope"]
  topics = [
    "docker-compose",
    "docker-image",
    "server",
    "wiki",
  ]
}

module "docker_poolcounter" {
  source                        = "./modules/github-repository"
  name                          = "docker-poolcounter"
  description                   = ":whale: Dockerized PoolCounter for MediaWiki"
  delete_branch_on_merge        = true
  enforce_admins                = local.docker.enforce_admins
  required_pull_request_reviews = local.docker.required_pull_request_reviews
  topics = [
    "docker-image",
    "mediawiki",
    "poolcounter",
  ]

  required_status_checks_contexts = [
    "hadolint",
    "rumdl",
    "actionlint",
  ]
  archived = true
}

module "rankingbot" {
  source                        = "./modules/github-repository"
  name                          = "rankingbot"
  description                   = ":robot: 랭킹봇"
  homepage_url                  = "https://femiwiki.com/w/%EC%82%AC%EC%9A%A9%EC%9E%90:%EB%9E%AD%ED%82%B9%EB%B4%87"
  enforce_admins                = local.bot.enforce_admins
  required_pull_request_reviews = local.bot.required_pull_request_reviews
  topics = [
    "bot",
  ]
  required_status_checks_contexts = ["ci", "ruff", "yamllint", "rumdl", "taplo", "biome"]
}

module "backupbot" {
  source                        = "./modules/github-repository"
  name                          = "backupbot"
  description                   = ":robot: 페미위키 MySQL 백업봇"
  enforce_admins                = local.bot.enforce_admins
  required_pull_request_reviews = local.bot.required_pull_request_reviews
  default_status_checks         = []
  topics = [
    "bot",
    "docker-image",
    "mysql",
  ]
  required_status_checks_contexts = ["hadolint", "rumdl", "yamllint", "actionlint", "shellcheck", "taplo"]
}

module "tweetbot" {
  source                        = "./modules/github-repository"
  name                          = "tweetbot"
  description                   = "🐦 페미위키 트위터 봇"
  homepage_url                  = "https://femiwiki.com/w/%EC%82%AC%EC%9A%A9%EC%9E%90:%ED%8A%B8%EC%9C%97%EB%B4%87"
  enforce_admins                = local.bot.enforce_admins
  required_pull_request_reviews = local.bot.required_pull_request_reviews
  topics = [
    "bot",
    "twitter",
  ]
  required_status_checks_contexts = ["ci", "ruff", "yamllint", "rumdl", "taplo"]
}

module "remote_gadgets" {
  source                = "./modules/github-repository"
  name                  = "remote-gadgets"
  description           = "📽️ External repository for JavaScript/CSS on Femiwiki"
  default_status_checks = []
  topics = [
    "bot",
  ]
  required_status_checks_contexts = ["taplo", "prettier", "ruff"]
}

module "femiwiki_github_io" {
  source           = "./modules/github-repository"
  name             = "femiwiki.github.io"
  description      = "Static pages published by the Femiwiki team"
  homepage_url     = "https://femiwiki.github.io/"
  pages_build_type = "workflow"
  required_status_checks_contexts = [
    "actionlint",
    "biome",
    "luacheck",
    "rumdl",
    "shellcheck",
    "stylua",
    "taplo",
    "yamllint",
  ]
  topics = [
    "static-site",
    "wikven",
  ]
}

module "dot_github" {
  source                          = "./modules/github-repository"
  name                            = ".github"
  description                     = "Community health files"
  default_status_checks           = []
  required_status_checks_contexts = ["prettier", "ruff", "taplo"]
}

module "legunto" {
  source                = "./modules/github-repository"
  name                  = "legunto"
  description           = "Fetch MediaWiki Scribunto modules from wikis"
  default_status_checks = []
  topics = [
    "scribunto",
  ]
  required_status_checks_contexts = ["ci", "yamllint", "actionlint", "rumdl", "taplo"]
}

module "caddy_mwcache" {
  source      = "./modules/github-repository"
  name        = "caddy-mwcache"
  description = ":wrench: Caddy anonymous cache plugin for MediaWiki"
  topics = [
    "caddy",
    "caddy2",
    "plugin",
    "caddy-plugin",
    "caddy-module",
    "cache",
    "mediawiki",
  ]
  required_status_checks_contexts = ["lint-go", "caddy-fmt", "rumdl", "yamllint", "biome", "parallel-lint", "phpcs", "taplo"]
}

module "ooui_femiwiki_theme" {
  source                = "./modules/github-repository"
  name                  = "OOUIFemiwikiTheme"
  description           = ":jack_o_lantern: OOUI Femiwiki Theme"
  default_status_checks = []
  topics = [
    "ooui-theme",
    "ooui",
    "theme",
  ]
  required_status_checks_contexts = ["parallel-lint", "phpcs", "shellcheck", "prettier"]
}

module "quibble_action" {
  source      = "./modules/github-repository"
  name        = "quibble-action"
  description = "⏯️ Quibble is for setting up a MediaWiki instance and running various tests against it."
  topics = [
    "quibble",
    "mediawiki",
    "github-actions",
  ]

  required_pull_request_reviews = []
  required_status_checks_contexts = [
    "semantic-pull-request",
    "yamllint",
    "ruff",
    "actionlint",
    "biome",
    "rumdl",
    "taplo",
  ]
}

module "lambda" {
  source                = "./modules/github-repository"
  name                  = "lambda"
  description           = "A simple lambda function which subscribes AWS SNS to ping Femiwiki's Discord webhook."
  default_status_checks = []
  topics = [
    "lambda",
    "aws",
    "rust",
  ]
  required_status_checks_contexts = ["fmt-prettier", "test", "taplo"]
}

module "terraform-provider-mediawiki" {
  source                = "./modules/github-repository"
  name                  = "terraform-provider-mediawiki"
  description           = "💜"
  default_status_checks = []
  topics = [
    "mediawiki",
    "terraform-provider",
  ]
  required_status_checks_contexts = ["rumdl", "actionlint"]
}

module "status" {
  source           = "./modules/github-repository"
  name             = "status"
  description      = ":green_heart: 페미위키가 지금 이용 가능한지"
  homepage_url     = "https://status.femiwiki.com"
  pages_build_type = "legacy"
  pages_cname      = "status.femiwiki.com"
  topics = [
    "status",
  ]
  required_status_checks_contexts = ["rumdl"]
}

resource "github_repository_file" "status_index" {
  repository          = module.status.name
  branch              = "main"
  file                = "index.html"
  content             = file("${path.module}/res/status-index.html")
  commit_message      = "Send a reader to the board"
  overwrite_on_create = true
}
