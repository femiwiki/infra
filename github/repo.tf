locals {
  default_repo = {
    # repository
    default_branch       = "main",
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
  default_branch       = local.with_cd.default_branch
  has_issues           = local.with_cd.has_issues
  vulnerability_alerts = local.with_cd.vulnerability_alerts
  archive_on_destroy   = local.with_cd.archive_on_destroy
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
  default_branch       = local.with_cd.default_branch
  has_issues           = local.with_cd.has_issues
  vulnerability_alerts = local.with_cd.vulnerability_alerts
  archive_on_destroy   = local.with_cd.archive_on_destroy
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
  default_branch       = local.default_repo.default_branch
  has_issues           = local.default_repo.has_issues
  vulnerability_alerts = local.default_repo.vulnerability_alerts
  archive_on_destroy   = local.default_repo.archive_on_destroy

  topics = [
    "feminism",
    "wiki",
  ]
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
  default_branch         = local.docker.default_branch
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
  default_branch       = local.docker.default_branch
  has_issues           = local.docker.has_issues
  vulnerability_alerts = local.docker.vulnerability_alerts
  archive_on_destroy   = local.docker.archive_on_destroy
  topics = [
    "docker-image",
    "parsoid",
  ]
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
  default_branch       = local.docker.default_branch
  has_issues           = local.docker.has_issues
  vulnerability_alerts = local.docker.vulnerability_alerts
  archive_on_destroy   = local.docker.archive_on_destroy
  topics = [
    "docker-image",
    "restbase"
  ]
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
  default_branch       = local.docker.default_branch
  has_issues           = local.docker.has_issues
  vulnerability_alerts = local.docker.vulnerability_alerts
  archive_on_destroy   = local.docker.archive_on_destroy
  topics = [
    "docker-image",
    "mathoid"
  ]
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
  default_branch       = local.bot.default_branch
  has_issues           = local.bot.has_issues
  vulnerability_alerts = local.bot.vulnerability_alerts
  archive_on_destroy   = local.bot.archive_on_destroy
  topics = [
    "bot",
    "docker-image",
  ]
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
  default_branch       = local.bot.default_branch
  has_issues           = local.bot.has_issues
  vulnerability_alerts = local.bot.vulnerability_alerts
  archive_on_destroy   = local.bot.archive_on_destroy
  topics = [
    "bot",
    "docker-image",
  ]
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
  default_branch       = local.bot.default_branch
  has_issues           = local.bot.has_issues
  vulnerability_alerts = local.bot.vulnerability_alerts
  archive_on_destroy   = local.bot.archive_on_destroy
  topics = [
    "bot",
    "docker-image",
  ]
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
  default_branch       = local.default_repo.default_branch
  has_issues           = local.default_repo.has_issues
  vulnerability_alerts = local.default_repo.vulnerability_alerts
  archive_on_destroy   = local.default_repo.archive_on_destroy
  topics               = ["bot"]
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
  default_branch       = local.default_repo.default_branch
  has_issues           = local.default_repo.has_issues
  vulnerability_alerts = local.default_repo.vulnerability_alerts
  archive_on_destroy   = local.default_repo.archive_on_destroy
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
#   default_branch       = local.default_repo.default_branch
#   has_issues           = local.default_repo.has_issues
#   vulnerability_alerts = local.default_repo.vulnerability_alerts
#   archive_on_destroy   = local.default_repo.archive_on_destroy
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
  default_branch       = local.default_repo.default_branch
  has_issues           = local.default_repo.has_issues
  vulnerability_alerts = local.default_repo.vulnerability_alerts
  archive_on_destroy   = local.default_repo.archive_on_destroy
  topics               = ["website"]
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
# caddy-mwcache
#
resource "github_repository" "caddy-mwcache" {
  name                 = "caddy-mwcache"
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

resource "github_team_repository" "caddy-mwcache" {
  team_id    = github_team.reviewer.id
  repository = github_repository.caddy-mwcache.name
}
