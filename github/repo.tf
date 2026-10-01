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
  enforce_admins                = false
  required_pull_request_reviews = local.with_cd.required_pull_request_reviews
  required_status_checks_contexts = [
    "lint gate",
    "tofu gate",
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
  required_status_checks_contexts = ["required"]
  default_status_checks           = []
}

module "docker_mediawiki" {
  source                          = "./modules/github-repository"
  name                            = "docker-mediawiki"
  description                     = ":whale: Dockerized Femiwiki's mediawiki server"
  delete_branch_on_merge          = true
  enforce_admins                  = local.docker.enforce_admins
  required_pull_request_reviews   = local.docker.required_pull_request_reviews
  required_status_checks_contexts = ["required", "title scope"]
  topics = [
    "docker-compose",
    "docker-image",
    "server",
    "wiki",
  ]
  default_status_checks = []
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
  required_status_checks_contexts = ["required"]
  default_status_checks           = []
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
  required_status_checks_contexts = ["required"]
  default_status_checks           = []
}

module "remote_gadgets" {
  source      = "./modules/github-repository"
  name        = "remote-gadgets"
  description = "📽️ External repository for JavaScript/CSS on Femiwiki"
  topics = [
    "bot",
  ]
  required_status_checks_contexts = ["required"]
  default_status_checks           = []
}

module "femiwiki_github_io" {
  source                          = "./modules/github-repository"
  name                            = "femiwiki.github.io"
  description                     = "Static pages published by the Femiwiki team"
  homepage_url                    = "https://femiwiki.github.io/"
  pages_build_type                = "workflow"
  required_status_checks_contexts = ["required"]
  topics = [
    "static-site",
    "wikven",
  ]
  default_status_checks = []
}

module "dot_github" {
  source                          = "./modules/github-repository"
  name                            = ".github"
  description                     = "Community health files"
  required_status_checks_contexts = ["required"]
  default_status_checks           = []
}

module "legunto" {
  source      = "./modules/github-repository"
  name        = "legunto"
  description = "Fetch MediaWiki Scribunto modules from wikis"
  topics = [
    "scribunto",
  ]
  required_status_checks_contexts = ["required"]
  default_status_checks           = []
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
  required_status_checks_contexts = ["required"]
  default_status_checks           = []
}

module "caddy_cloudfront_ip" {
  source      = "./modules/github-repository"
  name        = "caddy-cloudfront-ip"
  description = "Caddy IP source module that trusts CloudFront's origin-facing ranges"
  topics = [
    "caddy",
    "caddy2",
    "caddy-plugin",
    "caddy-module",
    "cloudfront",
  ]
  required_status_checks_contexts = ["required"]
  default_status_checks           = []
}

module "ooui_femiwiki_theme" {
  source      = "./modules/github-repository"
  name        = "OOUIFemiwikiTheme"
  description = ":jack_o_lantern: OOUI Femiwiki Theme"
  topics = [
    "ooui-theme",
    "ooui",
    "theme",
  ]
  required_status_checks_contexts = ["required"]
  default_status_checks           = []
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

  required_pull_request_reviews   = []
  required_status_checks_contexts = ["required", "semantic-pull-request"]
  default_status_checks           = []
}

module "terraform_github_tacos" {
  source      = "./modules/github-repository"
  name        = "terraform-github-tacos"
  description = "GitHub Actions and an OpenTofu module that plan in the PR and apply on environment approval"
  topics = [
    "github-actions",
    "opentofu",
    "tacos",
  ]

  required_pull_request_reviews   = []
  required_status_checks_contexts = ["required"]
  default_status_checks           = []
  pages_build_type                = "workflow"
  homepage_url                    = "https://femiwiki.github.io/terraform-github-tacos/"
}

module "lambda" {
  source      = "./modules/github-repository"
  name        = "lambda"
  description = "A simple lambda function which subscribes AWS SNS to ping Femiwiki's Discord webhook."
  topics = [
    "lambda",
    "aws",
    "rust",
  ]
  required_status_checks_contexts = ["required"]
  default_status_checks           = []
}

module "terraform-provider-mediawiki" {
  source      = "./modules/github-repository"
  name        = "terraform-provider-mediawiki"
  description = "💜"
  topics = [
    "mediawiki",
    "terraform-provider",
  ]
  required_status_checks_contexts = ["required"]
  default_status_checks           = []
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
  required_status_checks_contexts = ["required"]
  default_status_checks           = []
}

resource "github_repository_file" "status_index" {
  repository          = module.status.name
  branch              = "main"
  file                = "index.html"
  content             = file("${path.module}/res/status-index.html")
  commit_message      = "Send a reader to the board"
  overwrite_on_create = true
}

resource "github_repository_environment" "infra" {
  for_each = toset(["aws", "docker", "github", "grafana", "healthchecks"])

  repository  = module.infra.name
  environment = each.key

  # An apply waits here until someone approves it
  reviewers {
    teams = [github_team.deployer.id]
  }
}

moved {
  from = github_repository_environment.infra_docker
  to   = github_repository_environment.infra["docker"]
}

moved {
  from = github_repository_environment.infra_github
  to   = github_repository_environment.infra["github"]
}
