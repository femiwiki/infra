#
# infra
#
resource "github_repository" "infra" {
  name          = "infra"
  description   = ":evergreen_tree: Terraforming Femiwiki Infrastructure"
  has_downloads = true
  has_issues    = true
}

resource "github_branch_protection" "infra" {
  repository      = github_repository.infra.name
  branch          = "master"
  enforce_admins  = true

  required_pull_request_reviews {
    required_approving_review_count = 1
  }
}

#
# kubernetes
#
resource "github_repository" "kubernetes" {
  name        = "kubernetes"
  description = ":whale: Femiwiki kubernetes"
  has_issues  = true
}

resource "github_branch_protection" "kubernetes" {
  repository  = github_repository.kubernetes.name
  branch      = "master"

  required_pull_request_reviews {
    required_approving_review_count = 1
  }
}

#
# skin
#
resource "github_repository" "femiwiki_skin" {
  name          = "FemiwikiSkin"
  description   = ":jack_o_lantern: 페미위키 스킨"
  homepage_url  = "https://www.mediawiki.org/wiki/Special:MyLanguage/Skin:Femiwiki"
  has_downloads = true
  has_issues    = true
  has_projects  = false
  has_wiki      = false
  topics = [
    "mediawiki-skin",
  ]
}

resource "github_branch_protection" "femiwiki_skin" {
  repository      = github_repository.femiwiki_skin.name
  branch          = "master"
  enforce_admins  = true
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
    }
    FacetedCategory = {
      description = "FacetedCategories extension"
    }
    CategoryIntersectionSearch = {
      description = "provide special page show category intersection"
    }
    Sanctions = {
      description = "Offers convenient way to handle sanctions."
    }
    AchievementBadges = {
      description = "TBD"
    }
  }
}

resource "github_repository" "extensions" {
  for_each      = local.extensions
  name          = each.key
  description   = each.value.description
  homepage_url  = "https://www.mediawiki.org/wiki/Special:MyLanguage/Extension:${each.key}"
  has_downloads = true
  has_issues    = true
  has_projects  = false
  has_wiki      = false
  topics = [
    "mediawiki-extension",
  ]
}

resource "github_branch_protection" "extension_protections" {
  for_each        = local.extensions
  repository      = each.key
  branch          = "master"
  enforce_admins  = true
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
  name          = "femiwiki"
  description   = ":earth_asia: 문서화된 페미위키 기술 정보 및 이슈 트래킹 정보 제공"
  homepage_url  = "https://femiwiki.com"
  has_downloads = true
  has_issues    = true
  has_wiki      = false
  topics = [
    "feminism",
    "wiki",
  ]
}

resource "github_branch_protection" "femiwiki" {
  repository      = github_repository.femiwiki.name
  branch          = "master"

  required_pull_request_reviews {
    required_approving_review_count = 1
  }
}

#
# mediawiki
#
resource "github_repository" "docker_mediawiki" {
  name          = "docker-mediawiki"
  description   = ":whale: Dockerized Femiwiki's mediawiki server"
  has_downloads = true
  has_issues    = true
  topics = [
    "docker-compose",
    "docker-image",
    "server",
    "wiki",
  ]
}

resource "github_branch_protection" "mediawiki" {
  repository      = github_repository.docker_mediawiki.name
  branch          = "master"
  enforce_admins  = true

  required_pull_request_reviews {
    required_approving_review_count = 1
  }
}

#
# base
#
resource "github_repository" "base" {
  name          = "base"
  description   = ":whale: Base docker image of https://github.com/femiwiki/mediawiki to accelerate build speed"
  has_downloads = true
  has_issues    = true
  has_wiki      = false
  topics        = ["docker-image"]
}

resource "github_branch_protection" "base" {
  repository      = github_repository.base.name
  branch          = "master"
  enforce_admins  = true

  required_pull_request_reviews {
    required_approving_review_count = 1
  }
}

#
# base extensions
#
resource "github_repository" "base_extensions" {
  name          = "base-extensions"
  description   = ":whale: Base docker image of https://github.com/femiwiki/mediawiki to accelerate build speed"
  has_downloads = true
  has_issues    = true
  has_wiki      = false
  topics        = ["docker-image", ]
}

resource "github_branch_protection" "base_extensions" {
  repository      = github_repository.base_extensions.name
  branch          = "master"
  enforce_admins  = true

  required_pull_request_reviews {
    required_approving_review_count = 1
  }
}

#
# parsoid
#
resource "github_repository" "docker_parsoid" {
  name          = "docker-parsoid"
  description   = ":whale: Dockerized parsoid"
  has_downloads = true
  has_issues    = true
  has_wiki      = false
  topics = [
    "docker-image",
    "parsoid",
  ]
}

resource "github_branch_protection" "parsoid" {
  repository      = github_repository.docker_parsoid.name
  branch          = "master"
  enforce_admins  = true

  required_pull_request_reviews {
    required_approving_review_count = 1
  }
}

#
# restbase
#
resource "github_repository" "docker_restbase" {
  name          = "docker-restbase"
  description   = "📝 Dockerized RESTBase"
  has_downloads = true
  has_issues    = true
  has_wiki      = false
  topics = [
    "docker-image",
    "restbase"
  ]
}

resource "github_branch_protection" "docker_restbase" {
  repository      = github_repository.docker_restbase.name
  branch          = "master"
  enforce_admins  = true

  required_pull_request_reviews {
    required_approving_review_count = 1
  }
}

#
# rankingbot
#
resource "github_repository" "rankingbot" {
  name          = "rankingbot"
  description   = ":robot: 랭킹봇"
  homepage_url  = "https://femiwiki.com/w/%EC%82%AC%EC%9A%A9%EC%9E%90:%EB%9E%AD%ED%82%B9%EB%B4%87"
  has_downloads = true
  has_issues    = true
  has_wiki      = false
  topics = [
    "bot",
    "docker-image",
  ]
}

resource "github_branch_protection" "rankingbot" {
  repository      = github_repository.rankingbot.name
  branch          = "master"
  enforce_admins  = true

  required_pull_request_reviews {
    required_approving_review_count = 1
  }
}

#
# backupbot
#
resource "github_repository" "backupbot" {
  name          = "backupbot"
  description   = ":robot: 페미위키 MySQL 백업봇"
  has_downloads = true
  has_issues    = true
  has_wiki      = false
  topics = [
    "bot",
    "docker-image",
  ]
}

resource "github_branch_protection" "backupbot" {
  repository      = github_repository.backupbot.name
  branch          = "master"
  enforce_admins  = true

  required_pull_request_reviews {
    required_approving_review_count = 1
  }
}

#
# tweetbot
#
resource "github_repository" "tweetbot" {
  name          = "tweetbot"
  description   = ":robot: 페미위키 트위터 봇"
  homepage_url  = "https://femiwiki.com/w/%EC%82%AC%EC%9A%A9%EC%9E%90:%ED%8A%B8%EC%9C%97%EB%B4%87"
  has_downloads = true
  has_issues    = true
  has_wiki      = false
  topics = [
    "bot",
    "docker-image",
  ]
}

resource "github_branch_protection" "tweetbot" {
  repository      = github_repository.tweetbot.name
  branch          = "master"
  enforce_admins  = true

  required_pull_request_reviews {
    required_approving_review_count = 1
  }
}

#
# ami
#
resource "github_repository" "ami" {
  name          = "ami"
  description   = ":package: Base AMI of Femiwiki"
  archived      = true
  has_downloads = true
  has_issues    = true
  has_wiki      = false
}

resource "github_branch_protection" "ami" {
  repository = github_repository.ami.name
  branch     = "master"

  required_pull_request_reviews {
    required_approving_review_count = 1
  }
}

#
# remote gadgets
#
resource "github_repository" "remote_gadgets" {
  name         = "remote-gadgets"
  description  = "📽️ External repository for Javascript/CSS on FemiWiki"
  has_issues   = true
  has_wiki     = false
  auto_init    = true
  topics       = ["bot"]
}

resource "github_branch_protection" "remote_gadgets" {
  repository      = github_repository.remote_gadgets.name
  branch          = "master"
  enforce_admins  = true

  required_pull_request_reviews {
    required_approving_review_count = 1
  }
}


#
# maintenance
#
resource "github_repository" "maintenance" {
  name          = "maintenance"
  description   = ":wrench: 페미위키 점검 페이지"
  homepage_url  = "https://femiwiki.github.io/maintenance"
  has_downloads = true
  has_issues    = true
  topics        = ["website"]
}

resource "github_branch_protection" "maintenance" {
  repository      = github_repository.maintenance.name
  branch          = "master"

  required_pull_request_reviews {
    required_approving_review_count = 1
  }
}
