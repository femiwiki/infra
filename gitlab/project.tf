locals {
  repositories = toset([
    ".github",
    "AchievementBadges",
    "CategoryIntersectionSearch",
    "DiscordRCFeed",
    "FacetedCategory",
    "FemiwikiCrawlingBlocker",
    "FemiwikiSkin",
    "OOUIFemiwikiTheme",
    "PageViewInfoGA",
    "Sanctions",
    "UnifiedExtensionForFemiwiki",
    "ami",
    "backupbot",
    "base",
    "base-extensions",
    "caddy-mwcache",
    "cassandra",
    "database",
    "docker-mathoid",
    "docker-mediawiki",
    "docker-parsoid",
    "docker-poolcounter",
    "docker-restbase",
    "emailbot",
    "femiwiki",
    "femiwiki.github.io",
    "graphviz-lambda",
    "html2feed-lambda",
    "infra",
    "kakaotalk-chatloggen-lambda",
    "kubernetes",
    "lambda",
    "legunto",
    "maintenance",
    "mediawiki-extensions-LocalisationUpdate",
    "mediawiki-vagrant",
    "nomad",
    "quibble-action",
    "rankingbot",
    "remote-gadgets",
    "status",
    "terraform-github-tacos",
    "terraform-provider-mediawiki",
    "tweetbot",
  ])
}

resource "gitlab_project" "mirror" {
  for_each = local.repositories

  name               = each.key
  path               = each.key
  namespace_id       = data.gitlab_group.femiwiki.group_id
  description        = "Mirror of https://github.com/femiwiki/${each.key}"
  visibility_level   = "public"
  archive_on_destroy = true

  issues_access_level         = "disabled"
  merge_requests_access_level = "disabled"
  wiki_access_level           = "disabled"
  snippets_access_level       = "disabled"
  builds_access_level         = "disabled"
  pages_access_level          = "disabled"
  packages_enabled            = false
}

resource "gitlab_deploy_key" "mirror" {
  for_each = local.repositories

  project  = gitlab_project.mirror[each.key].id
  title    = "GitHub Actions of femiwiki/.github"
  key      = trimspace(file("${path.module}/res/mirror.pub"))
  can_push = true
}
