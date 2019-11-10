locals {
  github_organization = "femiwiki"
  github_admins = [
    "femiwiki-bot",
    "lens0021",
    "simnalamburt",
  ]
  github_members = [
    "765P",
    "choidamdam",
    "HanbitGaram",
    "vvvvviral",
  ]
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
  }
}

# Members

resource "github_membership" "admins" {
  for_each = toset(local.github_admins)

  username = each.key
  role     = "admin"
}

# Project

resource "github_organization_project" "dev" {
  name = "개발"
  body = ":shipit: 페미위키 관련된 기술적인 사안"
}

resource "github_project_column" "columns" {
  for_each = toset([
    "To do",
    "In Progress",
    "Blocked",
    "Done"
  ])

  project_id = github_organization_project.dev.id
  name       = each.key
}

resource "github_membership" "members" {
  for_each = toset(local.github_members)

  username = each.key
  role     = "member"
}

# Repositories

resource "github_repository" "infra" {
  name          = "infra"
  description   = ":evergreen_tree: Terraforming Femiwiki Infrastructure"
  has_downloads = true
  has_issues    = true
}

resource "github_branch_protection" "infra" {
  repository = github_repository.infra.name
  branch     = "master"

  required_pull_request_reviews {
    required_approving_review_count = 1
  }
}

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
  repository = github_repository.femiwiki_skin.name
  branch     = "master"
}

resource "github_repository_collaborator" "femiwiki_skin" {
  repository = github_repository.femiwiki_skin.name
  username   = "translatewiki"
  permission = "push"
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
  for_each   = local.extensions
  repository = each.key
  branch     = "master"
}

resource "github_repository_collaborator" "extension_collaborators" {
  for_each   = local.extensions
  repository = each.key
  username   = "translatewiki"
  permission = "push"
}

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
  repository = github_repository.femiwiki.name
  branch     = "master"

  required_pull_request_reviews {
    required_approving_review_count = 1
  }
}

resource "github_repository" "mediawiki" {
  name          = "mediawiki"
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
  repository = github_repository.mediawiki.name
  branch     = "master"

  required_pull_request_reviews {
    required_approving_review_count = 1
  }
}

resource "github_repository" "database" {
  name          = "database"
  description   = ":floppy_disk: 페미위키 데이터베이스 서버"
  has_downloads = true
  has_issues    = true
  has_wiki      = false
  topics = [
    "docker-compose",
    "server",
  ]
}

resource "github_branch_protection" "database" {
  repository = github_repository.database.name
  branch     = "master"

  required_pull_request_reviews {
    required_approving_review_count = 1
  }
}

resource "github_repository" "base" {
  name          = "base"
  description   = ":whale: Base docker image of https://github.com/femiwiki/mediawiki to accelerate build speed"
  has_downloads = true
  has_issues    = true
  has_wiki      = false
  topics        = ["docker-image"]
}

resource "github_branch_protection" "base" {
  repository = github_repository.base.name
  branch     = "master"

  required_pull_request_reviews {
    required_approving_review_count = 1
  }
}

resource "github_repository" "base_extensions" {
  name          = "base-extensions"
  description   = ":whale: Base docker image of https://github.com/femiwiki/mediawiki to accelerate build speed"
  has_downloads = true
  has_issues    = true
  has_wiki      = false
  topics        = ["docker-image", ]
}

resource "github_branch_protection" "base_extensions" {
  repository = github_repository.base_extensions.name
  branch     = "master"

  required_pull_request_reviews {
    required_approving_review_count = 1
  }
}

resource "github_repository" "parsoid" {
  name          = "parsoid"
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
  repository = github_repository.parsoid.name
  branch     = "master"

  required_pull_request_reviews {
    required_approving_review_count = 1
  }
}

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
  repository = github_repository.docker_restbase.name
  branch     = "master"

  required_pull_request_reviews {
    required_approving_review_count = 1
  }
}

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
  repository = github_repository.rankingbot.name
  branch     = "master"

  required_pull_request_reviews {
    required_approving_review_count = 1
  }
}

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
  repository = github_repository.backupbot.name
  branch     = "master"

  required_pull_request_reviews {
    required_approving_review_count = 1
  }
}

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
  repository = github_repository.tweetbot.name
  branch     = "master"

  required_pull_request_reviews {
    required_approving_review_count = 1
  }
}

resource "github_repository" "ami" {
  name          = "ami"
  description   = ":package: Base AMI of Femiwiki"
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

resource "github_repository" "maintenance" {
  name          = "maintenance"
  description   = ":wrench: 페미위키 점검 페이지"
  homepage_url  = "https://femiwiki.github.io/maintenance"
  has_downloads = true
  has_issues    = true
  topics        = ["website"]
}

resource "github_branch_protection" "maintenance" {
  repository = github_repository.maintenance.name
  branch     = "master"

  required_pull_request_reviews {
    required_approving_review_count = 1
  }
}

# Labels

data "github_repositories" "actives" {
  query = "org:femiwiki archived:false fork:false"
}

resource "github_issue_label" "note" {
  for_each    = toset(data.github_repositories.actives.names)
  repository  = each.key
  name        = "글쓰기"
  color       = "0075ca"
  description = "공지사항이나 블로그 글로 문서화해야하는 이슈"
}

resource "github_issue_label" "bug" {
  for_each    = toset(data.github_repositories.actives.names)
  repository  = each.key
  name        = "Bug"
  color       = "ee0701"
  description = ""
}

resource "github_issue_label" "enhancement" {
  for_each    = toset(data.github_repositories.actives.names)
  repository  = each.key
  name        = "enhancement"
  color       = "a2eeef"
  description = "New feature or request"
}

resource "github_issue_label" "wontfix" {
  for_each    = toset(data.github_repositories.actives.names)
  repository  = each.key
  name        = "wontfix"
  color       = "ffffff"
  description = "This will not be worked on"
}

resource "github_issue_label" "invalid" {
  for_each    = toset(data.github_repositories.actives.names)
  repository  = each.key
  name        = "invalid"
  color       = "e4e669"
  description = "This doesn't seem right"
}

resource "github_issue_label" "femiwki_discussion_needed" {
  for_each    = toset(data.github_repositories.actives.names)
  repository  = each.key
  name        = "femiwki discussion needed"
  color       = "d4c5f9"
  description = ""
}

resource "github_issue_label" "epic" {
  for_each    = toset(data.github_repositories.actives.names)
  repository  = each.key
  name        = "EPIC"
  color       = "fc7a6c"
  description = ""
}
