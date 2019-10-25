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

resource "github_repository" "unified_extension_for_femiwiki" {
  name          = "UnifiedExtensionForFemiwiki"
  description   = "Unified Extension For Femiwiki"
  has_downloads = true
  has_issues    = true
  has_projects  = false
  has_wiki      = false
  topics = [
    "mediawiki-extension",
  ]
}

resource "github_branch_protection" "unified_extension_for_femiwiki" {
  repository = github_repository.unified_extension_for_femiwiki.name
  branch     = "master"
}

resource "github_repository_collaborator" "unified_extension_for_femiwiki" {
  repository = github_repository.unified_extension_for_femiwiki.name
  username   = "translatewiki"
  permission = "push"
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

resource "github_repository" "faceted_category" {
  name          = "FacetedCategory"
  description   = "FacetedCategories extension"
  has_downloads = true
  has_issues    = true
  has_projects  = false
  has_wiki      = false
  topics = [
    "mediawiki-extension",
  ]
}

resource "github_branch_protection" "faceted_category" {
  repository = github_repository.faceted_category.name
  branch     = "master"
}

resource "github_repository_collaborator" "faceted_category" {
  repository = github_repository.faceted_category.name
  username   = "translatewiki"
  permission = "push"
}

resource "github_repository" "category_intersection_search" {
  name          = "CategoryIntersectionSearch"
  description   = "provide special page show category intersection"
  has_downloads = true
  has_issues    = true
  has_projects  = false
  has_wiki      = false
  topics = [
    "mediawiki-extension",
  ]
}

resource "github_branch_protection" "category_intersection_search" {
  repository = github_repository.category_intersection_search.name
  branch     = "master"
}

resource "github_repository_collaborator" "category_intersection_search" {
  repository = github_repository.category_intersection_search.name
  username   = "translatewiki"
  permission = "push"
}

resource "github_repository" "sanctions" {
  name          = "Sanctions"
  description   = "Offers convenient way to handle sanctions."
  homepage_url  = "https://www.mediawiki.org/wiki/Special:MyLanguage/Extension:Sanctions"
  has_downloads = true
  has_issues    = true
  has_projects  = false
  has_wiki      = false
  topics = [
    "mediawiki-extension",
  ]
}

resource "github_branch_protection" "sanctions" {
  repository = github_repository.sanctions.name
  branch     = "master"
}

resource "github_repository_collaborator" "sanctions" {
  repository = github_repository.sanctions.name
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

resource "github_repository" "restbase" {
  name          = "restbase"
  description   = "Distributed storage with REST API & dispatcher for backend services."
  homepage_url  = "https://www.mediawiki.org/wiki/RESTBase"
  has_downloads = true
  has_issues    = false
  has_wiki      = false
}

resource "github_repository" "restbase_mod_table_mysql" {
  name          = "restbase-mod-table-mysql"
  description   = "SQLite backend for RESTBase"
  homepage_url  = "https://www.mediawiki.org/wiki/RESTBase"
  has_downloads = true
  has_issues    = false
  has_wiki      = false
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

resource "github_repository" "DiscordNotifications" {
  name          = "DiscordNotifications"
  description   = "Integrate Discord with Mediawiki. Sends notifications into your Discord room when certain actions are being performed in your wiki (for example when article is being edited, new article was added...)"
  has_downloads = true
  has_wiki      = false
}

resource "github_repository" "maintenance" {
  name          = "maintenance"
  description   = ":wrench: 페미위키 점검 페이지"
  homepage_url  = "https://femiwiki.github.io/maintenance"
  has_downloads = true
  has_issues    = true
  topics        = ["website"]
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

resource "github_repository" "emailbot" {
  name          = "emailbot"
  description   = ":email: Femiwiki email bot"
  archived      = true
  has_downloads = true
  has_issues    = true
  has_wiki      = false
}

resource "github_repository" "base" {
  name          = "base"
  description   = ":whale: Base docker image of https://github.com/femiwiki/mediawiki to accelerate build speed"
  has_downloads = true
  has_issues    = true
  has_wiki      = false
  topics        = ["docker-image"]
}

resource "github_repository" "base_extensions" {
  name          = "base-extensions"
  description   = ":whale: Base docker image of https://github.com/femiwiki/mediawiki to accelerate build speed"
  has_downloads = true
  has_issues    = true
  has_wiki      = false
  topics = [
    "docker-image",
  ]
}

resource "github_repository" "cassandra" {
  name          = "cassandra"
  description   = "🐳 Dockerized Femiwiki's cassandra server"
  has_downloads = true
  has_issues    = true
  has_wiki      = false
  topics = [
    "cassandra",
    "docker-image",
  ]
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

resource "github_repository" "oojs_ui" {
  name         = "oojs-ui"
  description  = "OOUI is a modern JavaScript UI library with strong cross-browser support. It is the standard library for MediaWiki and Wikipedia. This is a mirror from https://gerrit.wikimedia.org. Main website:"
  homepage_url = "https://www.mediawiki.org/wiki/OOUI"
}

resource "github_repository" "ami" {
  name          = "ami"
  description   = ":package: Base AMI of Femiwiki"
  has_downloads = true
  has_issues    = true
  has_wiki      = false
}

resource "github_repository" "mediawiki_aws_s3" {
  name          = "mediawiki-aws-s3"
  description   = ""
  has_downloads = true
}

resource "github_repository" "html2feed_lambda" {
  name          = "html2feed-lambda"
  description   = ""
  has_downloads = true
  has_issues    = true
  archived      = true
}

resource "github_repository" "kakaotalk_chatloggen_lambda" {
  name          = "kakaotalk-chatloggen-lambda"
  description   = "카카오톡 대화로그 생성기"
  homepage_url  = "https://femiwiki.com/index.php?oldid=124894"
  archived      = true
  has_downloads = true
  has_issues    = true
}

resource "github_repository" "graphviz_lambda" {
  name          = "graphviz-lambda"
  description   = "A simple web service that renders DOT files as svg"
  has_downloads = true
  has_issues    = true
  archived      = true
}

resource "github_repository" "mediawiki_vagrant" {
  name          = "mediawiki-vagrant"
  description   = "Barebone installation of Mediawiki"
  has_downloads = true
  has_issues    = true
  archived      = true
}
