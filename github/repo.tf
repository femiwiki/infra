#
# infra
#
resource "github_repository" "infra" {
  name                 = "infra"
  description          = ":evergreen_tree: Terraforming Femiwiki Infrastructure"
  has_issues           = true
  vulnerability_alerts = true
  archive_on_destroy   = true
}

resource "github_branch_protection" "infra" {
  repository_id = github_repository.infra.node_id
  pattern       = "master"
  # enforce_admins = true
  push_restrictions = []

  required_pull_request_reviews {
    dismiss_stale_reviews           = false
    dismissal_restrictions          = []
    require_code_owner_reviews      = false
    required_approving_review_count = 1
  }
}

resource "github_team_repository" "infra" {
  team_id    = github_team.reviewer.id
  repository = github_repository.infra.name
  permission = "pull"
}

#
# kubernetes
#
resource "github_repository" "kubernetes" {
  name                 = "kubernetes"
  description          = ":whale: Femiwiki kubernetes"
  has_issues           = true
  archive_on_destroy   = true
  vulnerability_alerts = true
}

resource "github_branch_protection" "kubernetes" {
  repository_id     = github_repository.kubernetes.node_id
  pattern           = "master"
  push_restrictions = []

  required_pull_request_reviews {
    dismiss_stale_reviews           = false
    dismissal_restrictions          = []
    require_code_owner_reviews      = false
    required_approving_review_count = 1
  }
}

resource "github_team_repository" "kubernetes" {
  team_id    = github_team.reviewer.id
  repository = github_repository.kubernetes.name
}

#
# nomad
#
resource "github_repository" "nomad" {
  name               = "nomad"
  description        = ":whale: Femiwiki nomad"
  has_issues         = true
  archive_on_destroy = true
}

# resource "github_branch_protection" "nomad" {
#   repository_id = github_repository.nomad.node_id
#   pattern       = "master"
#
#   required_pull_request_reviews {
#     required_approving_review_count = 1
#   }
# }

resource "github_team_repository" "nomad" {
  team_id    = github_team.reviewer.id
  repository = github_repository.nomad.name
}

#
# skin
#
resource "github_repository" "femiwiki_skin" {
  name                 = "FemiwikiSkin"
  description          = ":jack_o_lantern: 페미위키 스킨"
  homepage_url         = "https://www.mediawiki.org/wiki/Special:MyLanguage/Skin:Femiwiki"
  has_issues           = true
  has_wiki             = false
  archive_on_destroy   = true
  vulnerability_alerts = true
  topics = [
    "mediawiki-skin",
  ]
}

resource "github_branch_protection" "femiwiki_skin" {
  repository_id = github_repository.femiwiki_skin.node_id
  pattern       = "master"
  # enforce_admins = true
  push_restrictions = []
}

resource "github_branch_protection" "femiwiki_skin_REL" {
  repository_id = github_repository.femiwiki_skin.node_id
  pattern       = "REL*"
  # enforce_admins = true
  push_restrictions = []
}

resource "github_team_repository" "femiwiki_skin" {
  team_id    = github_team.reviewer.id
  repository = github_repository.femiwiki_skin.name
}

resource "github_repository_collaborator" "femiwiki_skin" {
  repository = github_repository.femiwiki_skin.name
  username   = "translatewiki"
  permission = "push"
}

#
# extensions
#
locals {
  extensions = {
    UnifiedExtensionForFemiwiki = {
      description = "Unified Extension For Femiwiki"
      id          = data.github_repository.UnifiedExtensionForFemiwiki.node_id
    }
    FacetedCategory = {
      description = "FacetedCategories extension"
      id          = data.github_repository.FacetedCategory.node_id
    }
    CategoryIntersectionSearch = {
      description = "provide special page show category intersection"
      id          = data.github_repository.CategoryIntersectionSearch.node_id
    }
    Sanctions = {
      description = "🙅 Offers convenient way to handle sanctions."
      id          = data.github_repository.Sanctions.node_id
    }
    AchievementBadges = {
      description = "TBD"
      id          = data.github_repository.AchievementBadges.node_id
    }
  }
}

data "github_repository" "UnifiedExtensionForFemiwiki" {
  full_name = "femiwiki/UnifiedExtensionForFemiwiki"
}
data "github_repository" "FacetedCategory" {
  full_name = "femiwiki/FacetedCategory"
}
data "github_repository" "CategoryIntersectionSearch" {
  full_name = "femiwiki/CategoryIntersectionSearch"
}
data "github_repository" "Sanctions" {
  full_name = "femiwiki/Sanctions"
}
data "github_repository" "AchievementBadges" {
  full_name = "femiwiki/AchievementBadges"
}

resource "github_repository" "extensions" {
  for_each             = local.extensions
  name                 = each.key
  description          = each.value.description
  homepage_url         = "https://www.mediawiki.org/wiki/Special:MyLanguage/Extension:${each.key}"
  has_issues           = true
  has_wiki             = false
  archive_on_destroy   = true
  vulnerability_alerts = true
  topics = [
    "mediawiki-extension",
  ]
}

resource "github_branch_protection" "extension_protections" {
  for_each          = local.extensions
  repository_id     = each.value.id
  pattern           = "master"
  push_restrictions = []
  # enforce_admins = true
}

resource "github_branch_protection" "extension_protections_REL" {
  for_each          = local.extensions
  repository_id     = each.value.id
  pattern           = "REL*"
  push_restrictions = []
  # enforce_admins = true
}

resource "github_team_repository" "extensions" {
  for_each   = local.extensions
  team_id    = github_team.reviewer.id
  repository = each.key
}

resource "github_repository_collaborator" "extension_collaborators" {
  for_each   = local.extensions
  repository = each.key
  username   = "translatewiki"
  permission = "push"
}

#
# femiwiki
#
resource "github_repository" "femiwiki" {
  name                 = "femiwiki"
  description          = ":earth_asia: 문서화된 페미위키 기술 정보 및 이슈 트래킹 정보 제공"
  homepage_url         = "https://femiwiki.com"
  has_issues           = true
  has_wiki             = false
  archive_on_destroy   = true
  vulnerability_alerts = true
  topics = [
    "feminism",
    "wiki",
  ]
}

resource "github_branch_protection" "femiwiki" {
  repository_id     = github_repository.femiwiki.node_id
  pattern           = "master"
  push_restrictions = []

  required_pull_request_reviews {
    dismiss_stale_reviews           = false
    dismissal_restrictions          = []
    require_code_owner_reviews      = false
    required_approving_review_count = 1
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
  has_issues             = true
  delete_branch_on_merge = true
  archive_on_destroy     = true
  vulnerability_alerts   = true
  topics = [
    "docker-compose",
    "docker-image",
    "server",
    "wiki",
  ]
}

# https://github.com/femiwiki/infra/issues/59
# resource "github_branch_protection" "mediawiki" {
#   repository_id = github_repository.docker_mediawiki.node_id
#   pattern       = "master"
#   enforce_admins = true
#
#   required_pull_request_reviews {
#     required_approving_review_count = 1
#   }
# }

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
  has_issues           = true
  has_wiki             = false
  archive_on_destroy   = true
  vulnerability_alerts = true
  topics = [
    "docker-image",
    "parsoid",
  ]
}

resource "github_branch_protection" "parsoid" {
  repository_id = github_repository.docker_parsoid.node_id
  pattern       = "master"
  # enforce_admins = true
  push_restrictions = []

  required_pull_request_reviews {
    dismiss_stale_reviews           = false
    dismissal_restrictions          = []
    require_code_owner_reviews      = false
    required_approving_review_count = 1
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
  has_issues           = true
  has_wiki             = false
  archive_on_destroy   = true
  vulnerability_alerts = true
  topics = [
    "docker-image",
    "restbase"
  ]
}

resource "github_branch_protection" "docker_restbase" {
  repository_id     = github_repository.docker_restbase.node_id
  pattern           = "master"
  push_restrictions = []
  # enforce_admins = true

  required_pull_request_reviews {
    dismiss_stale_reviews           = false
    dismissal_restrictions          = []
    require_code_owner_reviews      = false
    required_approving_review_count = 1
  }
}

resource "github_team_repository" "docker_restbase" {
  team_id    = github_team.reviewer.id
  repository = github_repository.docker_restbase.name
}

#
# rankingbot
#
resource "github_repository" "rankingbot" {
  name                 = "rankingbot"
  description          = ":robot: 랭킹봇"
  homepage_url         = "https://femiwiki.com/w/%EC%82%AC%EC%9A%A9%EC%9E%90:%EB%9E%AD%ED%82%B9%EB%B4%87"
  has_issues           = true
  has_wiki             = false
  archive_on_destroy   = true
  vulnerability_alerts = true
  topics = [
    "bot",
    "docker-image",
  ]
}

resource "github_branch_protection" "rankingbot" {
  repository_id = github_repository.rankingbot.node_id
  pattern       = "master"
  # enforce_admins = true
  push_restrictions = []

  required_pull_request_reviews {
    dismiss_stale_reviews           = false
    dismissal_restrictions          = []
    require_code_owner_reviews      = false
    required_approving_review_count = 1
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
  has_issues           = true
  has_wiki             = false
  archive_on_destroy   = true
  vulnerability_alerts = true
  topics = [
    "bot",
    "docker-image",
  ]
}

resource "github_branch_protection" "backupbot" {
  repository_id     = github_repository.backupbot.node_id
  pattern           = "master"
  push_restrictions = []
  # enforce_admins = true

  required_pull_request_reviews {
    dismiss_stale_reviews           = false
    dismissal_restrictions          = []
    require_code_owner_reviews      = false
    required_approving_review_count = 1
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
  has_issues           = true
  has_wiki             = false
  archive_on_destroy   = true
  vulnerability_alerts = true
  topics = [
    "bot",
    "docker-image",
  ]
}

resource "github_branch_protection" "tweetbot" {
  repository_id = github_repository.tweetbot.node_id
  pattern       = "master"
  # enforce_admins = true
  push_restrictions = []

  required_pull_request_reviews {
    dismiss_stale_reviews           = false
    dismissal_restrictions          = []
    require_code_owner_reviews      = false
    required_approving_review_count = 1
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
  has_issues           = true
  has_wiki             = false
  auto_init            = true
  archive_on_destroy   = true
  vulnerability_alerts = true
  topics               = ["bot"]
}

resource "github_branch_protection" "remote_gadgets" {
  repository_id = github_repository.remote_gadgets.node_id
  pattern       = "master"
  # enforce_admins = true
  push_restrictions = []

  required_pull_request_reviews {
    dismiss_stale_reviews           = false
    dismissal_restrictions          = []
    require_code_owner_reviews      = false
    required_approving_review_count = 1
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
  has_issues           = true
  archive_on_destroy   = true
  vulnerability_alerts = true
}

resource "github_team_repository" "dot_github" {
  team_id    = github_team.reviewer.id
  repository = github_repository.dot_github.name
}

#
# maintenance
#
resource "github_repository" "maintenance" {
  name                 = "maintenance"
  description          = ":wrench: 페미위키 점검 페이지"
  homepage_url         = "https://femiwiki.github.io/maintenance"
  has_issues           = true
  archive_on_destroy   = true
  vulnerability_alerts = true
  topics               = ["website"]
}

resource "github_branch_protection" "maintenance" {
  repository_id     = github_repository.maintenance.node_id
  pattern           = "master"
  push_restrictions = []

  required_pull_request_reviews {
    dismiss_stale_reviews           = false
    dismissal_restrictions          = []
    require_code_owner_reviews      = false
    required_approving_review_count = 1
  }
}

resource "github_team_repository" "maintenance" {
  team_id    = github_team.reviewer.id
  repository = github_repository.maintenance.name
}
