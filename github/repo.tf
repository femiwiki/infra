locals {
  default_repo = {
    # repository
    has_issues           = true,
    vulnerability_alerts = true,
    archive_on_destroy   = true,

    # branch_protection
    pattern                         = "main"
    push_restrictions               = [],
    enforce_admins                  = false,
    dismiss_stale_reviews           = false,
    require_code_owner_reviews      = false,
    required_approving_review_count = 1,
  }
  with_cd = merge(local.default_repo, {
    # enforce_admins is temporarily disabled due to too few development members.
    enforce_admins = false,
  })
  docker = merge(local.default_repo, {
    # enforce_admins is temporarily disabled due to too few development members.
    enforce_admins = false,
  })
  bot = local.with_cd
}

#
# infra
#
resource "github_repository" "infra" {
  name                 = "infra"
  description          = ":evergreen_tree: Terraforming Femiwiki Infrastructure"
  has_issues           = local.with_cd.has_issues
  vulnerability_alerts = local.with_cd.vulnerability_alerts
  archive_on_destroy   = local.with_cd.archive_on_destroy
}

resource "github_branch" "infra_main" {
  repository = github_repository.infra
  branch     = "main"
}

resource "github_branch_default" "infra" {
  repository = github.repository.infra
  branch     = github.branch.infra_main
}

resource "github_branch_protection" "infra" {
  repository_id     = github_repository.infra.node_id
  pattern           = local.with_cd.pattern
  enforce_admins    = local.with_cd.enforce_admins
  push_restrictions = local.with_cd.push_restrictions

  required_pull_request_reviews {
    dismiss_stale_reviews           = local.with_cd.dismiss_stale_reviews
    require_code_owner_reviews      = local.with_cd.require_code_owner_reviews
    required_approving_review_count = local.with_cd.required_approving_review_count
  }
}

resource "github_team_repository" "infra" {
  team_id    = github_team.reviewer.id
  repository = github_repository.infra.name
}

#
# nomad
#
resource "github_repository" "nomad" {
  name                 = "nomad"
  description          = ":whale: Femiwiki nomad"
  has_issues           = local.with_cd.has_issues
  vulnerability_alerts = local.with_cd.vulnerability_alerts
  archive_on_destroy   = local.with_cd.archive_on_destroy
}

resource "github_branch" "nomad_main" {
  repository = github_repository.nomad
  branch     = "master"
}

resource "github_branch_default" "nomad" {
  repository = github.repository.nomad
  branch     = github.branch.nomad_main
}

resource "github_branch_protection" "nomad" {
  repository_id     = github_repository.nomad.node_id
  pattern           = local.with_cd.pattern
  enforce_admins    = local.with_cd.enforce_admins
  push_restrictions = local.with_cd.push_restrictions

  required_pull_request_reviews {
    dismiss_stale_reviews           = local.with_cd.dismiss_stale_reviews
    require_code_owner_reviews      = local.with_cd.require_code_owner_reviews
    required_approving_review_count = local.with_cd.required_approving_review_count
  }
}

resource "github_team_repository" "nomad" {
  team_id    = github_team.reviewer.id
  repository = github_repository.nomad.name
}

#
# femiwiki
#
resource "github_repository" "femiwiki" {
  name                 = "femiwiki"
  description          = ":earth_asia: 문서화된 페미위키 기술 정보 및 이슈 트래킹 정보 제공"
  homepage_url         = "https://femiwiki.com"
  has_issues           = local.default_repo.has_issues
  vulnerability_alerts = local.default_repo.vulnerability_alerts
  archive_on_destroy   = local.default_repo.archive_on_destroy

  topics = [
    "feminism",
    "wiki",
  ]
}

resource "github_branch" "femiwiki_main" {
  repository = github_repository.femiwiki
  branch     = "main"
}

resource "github_branch_default" "femiwiki" {
  repository = github.repository.femiwiki
  branch     = github.branch.femiwiki_main
}

resource "github_branch_protection" "femiwiki" {
  repository_id     = github_repository.femiwiki.node_id
  pattern           = local.default_repo.pattern
  enforce_admins    = local.default_repo.enforce_admins
  push_restrictions = local.default_repo.push_restrictions

  required_pull_request_reviews {
    dismiss_stale_reviews           = local.default_repo.dismiss_stale_reviews
    require_code_owner_reviews      = local.default_repo.require_code_owner_reviews
    required_approving_review_count = local.default_repo.required_approving_review_count
  }
}

resource "github_team_repository" "femiwiki" {
  team_id    = github_team.reviewer.id
  repository = github_repository.femiwiki.name
}

#
# mediawiki
#
resource "github_repository" "docker_mediawiki" {
  name                   = "docker-mediawiki"
  description            = ":whale: Dockerized Femiwiki's mediawiki server"
  delete_branch_on_merge = true
  has_issues             = local.docker.has_issues
  vulnerability_alerts   = local.docker.vulnerability_alerts
  archive_on_destroy     = local.docker.archive_on_destroy
  topics = [
    "docker-compose",
    "docker-image",
    "server",
    "wiki",
  ]
}

resource "github_branch" "mediawiki_main" {
  repository = github_repository.mediawiki
  branch     = "main"
}

resource "github_branch_default" "mediawiki" {
  repository = github.repository.mediawiki
  branch     = github.branch.mediawiki_main
}

resource "github_branch_protection" "mediawiki" {
  repository_id = github_repository.docker_mediawiki.node_id
  pattern       = local.docker.pattern
  # Disabled for https://github.com/femiwiki/infra/issues/59
  enforce_admins    = false
  push_restrictions = local.docker.push_restrictions

  required_pull_request_reviews {
    dismiss_stale_reviews           = local.docker.dismiss_stale_reviews
    require_code_owner_reviews      = local.docker.require_code_owner_reviews
    required_approving_review_count = local.docker.required_approving_review_count
  }
}

resource "github_team_repository" "mediawiki" {
  team_id    = github_team.reviewer.id
  repository = github_repository.docker_mediawiki.name
}

#
# parsoid
#
resource "github_repository" "docker_parsoid" {
  name                 = "docker-parsoid"
  description          = ":whale: Dockerized parsoid"
  has_issues           = local.docker.has_issues
  vulnerability_alerts = local.docker.vulnerability_alerts
  archive_on_destroy   = local.docker.archive_on_destroy
  topics = [
    "docker-image",
    "parsoid",
  ]
}

resource "github_branch" "parsoid_main" {
  repository = github_repository.parsoid
  branch     = "main"
}

resource "github_branch_default" "parsoid" {
  repository = github.repository.parsoid
  branch     = github.branch.parsoid_main
}

resource "github_branch_protection" "parsoid" {
  repository_id     = github_repository.docker_parsoid.node_id
  pattern           = local.docker.pattern
  enforce_admins    = local.docker.enforce_admins
  push_restrictions = local.docker.push_restrictions

  required_pull_request_reviews {
    dismiss_stale_reviews           = local.docker.dismiss_stale_reviews
    require_code_owner_reviews      = local.docker.require_code_owner_reviews
    required_approving_review_count = local.docker.required_approving_review_count
  }
}

resource "github_team_repository" "parsoid" {
  team_id    = github_team.reviewer.id
  repository = github_repository.docker_parsoid.name
}

#
# restbase
#
resource "github_repository" "docker_restbase" {
  name                 = "docker-restbase"
  description          = "📝 Dockerized RESTBase"
  has_issues           = local.docker.has_issues
  vulnerability_alerts = local.docker.vulnerability_alerts
  archive_on_destroy   = local.docker.archive_on_destroy
  topics = [
    "docker-image",
    "restbase"
  ]
}

resource "github_branch" "docker_restbase_main" {
  repository = github_repository.docker_restbase
  branch     = "main"
}

resource "github_branch_default" "docker_restbase" {
  repository = github.repository.docker_restbase
  branch     = github.branch.docker_restbase_main
}

resource "github_branch_protection" "docker_restbase" {
  repository_id     = github_repository.docker_restbase.node_id
  pattern           = local.docker.pattern
  enforce_admins    = local.docker.enforce_admins
  push_restrictions = local.docker.push_restrictions

  required_pull_request_reviews {
    dismiss_stale_reviews           = local.docker.dismiss_stale_reviews
    require_code_owner_reviews      = local.docker.require_code_owner_reviews
    required_approving_review_count = local.docker.required_approving_review_count
  }
}

resource "github_team_repository" "docker_restbase" {
  team_id    = github_team.reviewer.id
  repository = github_repository.docker_restbase.name
}

#
# restbase
#
resource "github_repository" "docker_mathoid" {
  name                 = "docker-mathoid"
  description          = "📝 Dockerized Mathoid"
  has_issues           = local.docker.has_issues
  vulnerability_alerts = local.docker.vulnerability_alerts
  archive_on_destroy   = local.docker.archive_on_destroy
  topics = [
    "docker-image",
    "mathoid"
  ]
}

resource "github_branch" "docker_mathoid_main" {
  repository = github_repository.docker_mathoid
  branch     = "main"
}

resource "github_branch_default" "docker_mathoid" {
  repository = github.repository.docker_mathoid
  branch     = github.branch.docker_mathoid_main
}

resource "github_branch_protection" "docker_mathoid" {
  repository_id     = github_repository.docker_mathoid.node_id
  pattern           = local.docker.pattern
  enforce_admins    = local.docker.enforce_admins
  push_restrictions = local.docker.push_restrictions

  required_pull_request_reviews {
    dismiss_stale_reviews           = local.docker.dismiss_stale_reviews
    require_code_owner_reviews      = local.docker.require_code_owner_reviews
    required_approving_review_count = local.docker.required_approving_review_count
  }
}

resource "github_team_repository" "docker_mathoid" {
  team_id    = github_team.reviewer.id
  repository = github_repository.docker_mathoid.name
}

#
# rankingbot
#
resource "github_repository" "rankingbot" {
  name                 = "rankingbot"
  description          = ":robot: 랭킹봇"
  homepage_url         = "https://femiwiki.com/w/%EC%82%AC%EC%9A%A9%EC%9E%90:%EB%9E%AD%ED%82%B9%EB%B4%87"
  has_issues           = local.bot.has_issues
  vulnerability_alerts = local.bot.vulnerability_alerts
  archive_on_destroy   = local.bot.archive_on_destroy
  topics = [
    "bot",
    "docker-image",
  ]
}

resource "github_branch" "rankingbot_main" {
  repository = github_repository.rankingbot
  branch     = "main"
}

resource "github_branch_default" "rankingbot" {
  repository = github.repository.rankingbot
  branch     = github.branch.rankingbot_main
}

resource "github_branch_protection" "rankingbot" {
  repository_id     = github_repository.rankingbot.node_id
  pattern           = local.bot.pattern
  enforce_admins    = local.bot.enforce_admins
  push_restrictions = local.bot.push_restrictions

  required_pull_request_reviews {
    dismiss_stale_reviews           = local.bot.dismiss_stale_reviews
    require_code_owner_reviews      = local.bot.require_code_owner_reviews
    required_approving_review_count = local.bot.required_approving_review_count
  }
}

resource "github_team_repository" "rankingbot" {
  team_id    = github_team.reviewer.id
  repository = github_repository.rankingbot.name
}

#
# backupbot
#
resource "github_repository" "backupbot" {
  name                 = "backupbot"
  description          = ":robot: 페미위키 MySQL 백업봇"
  has_issues           = local.bot.has_issues
  vulnerability_alerts = local.bot.vulnerability_alerts
  archive_on_destroy   = local.bot.archive_on_destroy
  topics = [
    "bot",
    "docker-image",
  ]
}

resource "github_branch" "backupbot_main" {
  repository = github_repository.backupbot
  branch     = "main"
}

resource "github_branch_default" "backupbot" {
  repository = github.repository.backupbot
  branch     = github.branch.backupbot_main
}

resource "github_branch_protection" "backupbot" {
  repository_id     = github_repository.backupbot.node_id
  pattern           = local.bot.pattern
  enforce_admins    = local.bot.enforce_admins
  push_restrictions = local.bot.push_restrictions

  required_pull_request_reviews {
    dismiss_stale_reviews           = local.bot.dismiss_stale_reviews
    require_code_owner_reviews      = local.bot.require_code_owner_reviews
    required_approving_review_count = local.bot.required_approving_review_count
  }
}

resource "github_team_repository" "backupbot" {
  team_id    = github_team.reviewer.id
  repository = github_repository.backupbot.name
}

#
# tweetbot
#
resource "github_repository" "tweetbot" {
  name                 = "tweetbot"
  description          = ":robot: 페미위키 트위터 봇"
  homepage_url         = "https://femiwiki.com/w/%EC%82%AC%EC%9A%A9%EC%9E%90:%ED%8A%B8%EC%9C%97%EB%B4%87"
  has_issues           = local.bot.has_issues
  vulnerability_alerts = local.bot.vulnerability_alerts
  archive_on_destroy   = local.bot.archive_on_destroy
  topics = [
    "bot",
    "docker-image",
  ]
}

resource "github_branch" "tweetbot_main" {
  repository = github_repository.tweetbot
  branch     = "main"
}

resource "github_branch_default" "tweetbot" {
  repository = github.repository.tweetbot
  branch     = github.branch.tweetbot_main
}

resource "github_branch_protection" "tweetbot" {
  repository_id     = github_repository.tweetbot.node_id
  pattern           = local.bot.pattern
  enforce_admins    = local.bot.enforce_admins
  push_restrictions = local.bot.push_restrictions

  required_pull_request_reviews {
    dismiss_stale_reviews           = local.bot.dismiss_stale_reviews
    require_code_owner_reviews      = local.bot.require_code_owner_reviews
    required_approving_review_count = local.bot.required_approving_review_count
  }
}

resource "github_team_repository" "tweetbot" {
  team_id    = github_team.reviewer.id
  repository = github_repository.tweetbot.name
}

#
# remote gadgets
#
resource "github_repository" "remote_gadgets" {
  name                 = "remote-gadgets"
  description          = "📽️ External repository for Javascript/CSS on FemiWiki"
  has_issues           = local.default_repo.has_issues
  vulnerability_alerts = local.default_repo.vulnerability_alerts
  archive_on_destroy   = local.default_repo.archive_on_destroy
  topics               = ["bot"]
}

resource "github_branch" "remote_gadgets_main" {
  repository = github_repository.remote_gadgets
  branch     = "main"
}

resource "github_branch_default" "remote_gadgets" {
  repository = github.repository.remote_gadgets
  branch     = github.branch.remote_gadgets_main
}

resource "github_branch_protection" "remote_gadgets" {
  repository_id     = github_repository.remote_gadgets.node_id
  pattern           = local.default_repo.pattern
  enforce_admins    = local.default_repo.enforce_admins
  push_restrictions = local.default_repo.push_restrictions

  required_pull_request_reviews {
    dismiss_stale_reviews           = local.default_repo.dismiss_stale_reviews
    require_code_owner_reviews      = local.default_repo.require_code_owner_reviews
    required_approving_review_count = local.default_repo.required_approving_review_count
  }
}

resource "github_team_repository" "remote_gadgets" {
  team_id    = github_team.reviewer.id
  repository = github_repository.remote_gadgets.name
}

#
# .github
#
resource "github_repository" "dot_github" {
  name                 = ".github"
  description          = "Community health files"
  has_issues           = local.default_repo.has_issues
  vulnerability_alerts = local.default_repo.vulnerability_alerts
  archive_on_destroy   = local.default_repo.archive_on_destroy
}

resource "github_branch" "dot_github_main" {
  repository = github_repository.dot_github
  branch     = "main"
}

resource "github_branch_default" "dot_github" {
  repository = github.repository.dot_github
  branch     = github.branch.dot_github_main
}

resource "github_branch_protection" "dot_github" {
  repository_id     = github_repository.dot_github.node_id
  pattern           = local.default_repo.pattern
  enforce_admins    = local.default_repo.enforce_admins
  push_restrictions = local.default_repo.push_restrictions

  required_pull_request_reviews {
    dismiss_stale_reviews           = local.default_repo.dismiss_stale_reviews
    require_code_owner_reviews      = local.default_repo.require_code_owner_reviews
    required_approving_review_count = local.default_repo.required_approving_review_count
  }
}

resource "github_team_repository" "dot_github" {
  team_id    = github_team.reviewer.id
  repository = github_repository.dot_github.name
}

#
# legunto
# Commented because of https://github.com/femiwiki/infra/issues/78
#
# resource "github_repository" "legunto" {
#   name                 = "legunto"
#   description          = "Fetch MediaWiki Scribunto modules from wikis"
#   has_issues           = local.default_repo.has_issues
#   vulnerability_alerts = local.default_repo.vulnerability_alerts
#   archive_on_destroy   = local.default_repo.archive_on_destroy
# }

# resource "github_branch" "legunto_main" {
#   repository = github_repository.legunto
#   branch     = "main"
# }

# resource "github_branch_default" "legunto" {
#   repository = github.repository.legunto
#   branch     = github.branch.legunto_main
# }

# resource "github_branch_protection" "legunto" {
#   repository_id     = github_repository.legunto.node_id
#   pattern           = local.default_repo.pattern
#   enforce_admins    = local.default_repo.enforce_admins
#   push_restrictions = local.default_repo.push_restrictions

#   required_pull_request_reviews {
#     dismiss_stale_reviews           = local.default_repo.dismiss_stale_reviews
#     require_code_owner_reviews      = local.default_repo.require_code_owner_reviews
#     required_approving_review_count = local.default_repo.required_approving_review_count
#   }
# }

# resource "github_team_repository" "legunto" {
#   team_id    = github_team.reviewer.id
#   repository = github_repository.legunto.name
# }

#
# maintenance
#
resource "github_repository" "maintenance" {
  name                 = "maintenance"
  description          = ":wrench: 페미위키 점검 페이지"
  homepage_url         = "https://femiwiki.github.io/maintenance"
  has_issues           = local.default_repo.has_issues
  vulnerability_alerts = local.default_repo.vulnerability_alerts
  archive_on_destroy   = local.default_repo.archive_on_destroy
  topics               = ["website"]
}

resource "github_branch" "maintenance_main" {
  repository = github_repository.maintenance
  branch     = "main"
}

resource "github_branch_default" "maintenance" {
  repository = github.repository.maintenance
  branch     = github.branch.maintenance_main
}

resource "github_branch_protection" "maintenance" {
  repository_id     = github_repository.maintenance.node_id
  pattern           = local.default_repo.pattern
  enforce_admins    = local.default_repo.enforce_admins
  push_restrictions = local.default_repo.push_restrictions

  required_pull_request_reviews {
    dismiss_stale_reviews           = local.default_repo.dismiss_stale_reviews
    require_code_owner_reviews      = local.default_repo.require_code_owner_reviews
    required_approving_review_count = local.default_repo.required_approving_review_count
  }
}

resource "github_team_repository" "maintenance" {
  team_id    = github_team.reviewer.id
  repository = github_repository.maintenance.name
}

#
# caddy-wmcache
#
resource "github_repository" "caddy-wmcache" {
  name                 = "caddy-wmcache"
  description          = ":wrench: Caddy anonymous cache plugin for MediaWiki"
  default_branch       = local.default_repo.default_branch
  has_issues           = local.default_repo.has_issues
  vulnerability_alerts = local.default_repo.vulnerability_alerts
  archive_on_destroy   = local.default_repo.archive_on_destroy
}

#resource "github_branch_protection" "caddy-wmcache" {
#  repository_id     = github_repository.maintenance.node_id
#  pattern           = local.default_repo.pattern
#  enforce_admins    = local.default_repo.enforce_admins
#  push_restrictions = local.default_repo.push_restrictions
#
#  required_pull_request_reviews {
#    dismiss_stale_reviews           = local.default_repo.dismiss_stale_reviews
#    require_code_owner_reviews      = local.default_repo.require_code_owner_reviews
#    required_approving_review_count = local.default_repo.required_approving_review_count
#  }
#}

resource "github_team_repository" "caddy-wmcache" {
  team_id    = github_team.reviewer.id
  repository = github_repository.maintenance.name
}
