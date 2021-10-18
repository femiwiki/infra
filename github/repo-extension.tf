locals {
  extension_patterns = [
    # Cannot protect translatable branches now.
    # See https://phabricator.wikimedia.org/T235938#5592510 for detail.
    # "main",
    "REL[0-9]_[0-9][0-9]"
  ]
  extension_collaborator = true

  skin = merge(local.default_repo, {
    enforce_admins = true,
    # temporarily disable requiring reviews due to too few development members.
    required_pull_request_reviews   = [],
    required_status_checks_contexts = [["test"]]
    topics = [
      "mediawiki-skin",
    ],
    patterns     = local.extension_patterns,
    collaborator = local.extension_collaborator,
  })

  # local.default_repo is defined in repo.tf
  extension = merge(local.default_repo, {
    enforce_admins = true,
    # temporarily disable requiring reviews due to too few development members.
    required_pull_request_reviews   = [],
    required_status_checks_contexts = [["test"]]

    topics = [
      "mediawiki-extension",
    ],
    patterns     = local.extension_patterns,
    collaborator = local.extension_collaborator,
  })
}

# skin
module "femiwiki_skin" {
  source                          = "./modules/github-repository"
  name                            = "FemiwikiSkin"
  description                     = ":jack_o_lantern: FemiwikiSkin"
  homepage_url                    = "https://www.mediawiki.org/wiki/Special:MyLanguage/Skin:Femiwiki"
  topics                          = local.skin.topics
  enforce_admins                  = local.skin.enforce_admins
  required_pull_request_reviews   = local.skin.required_pull_request_reviews
  required_status_checks_contexts = local.skin.required_status_checks_contexts
  patterns                        = local.skin.patterns
  collaborator                    = local.skin.collaborator
}

# extensions

module "unified_extension_for_femiwiki" {
  source                          = "./modules/github-repository"
  name                            = "UnifiedExtensionForFemiwiki"
  description                     = "Unified Extension For Femiwiki"
  homepage_url                    = "https://www.mediawiki.org/wiki/Special:MyLanguage/Extension:UnifiedExtensionForFemiwiki"
  topics                          = local.extension.topics
  enforce_admins                  = local.extension.enforce_admins
  required_pull_request_reviews   = local.extension.required_pull_request_reviews
  required_status_checks_contexts = local.extension.required_status_checks_contexts
  patterns                        = local.extension.patterns
  collaborator                    = local.extension.collaborator
}

module "faceted_category" {
  source                          = "./modules/github-repository"
  name                            = "FacetedCategory"
  description                     = "FacetedCategories extension"
  homepage_url                    = "https://www.mediawiki.org/wiki/Special:MyLanguage/Extension:FacetedCategory"
  topics                          = local.extension.topics
  enforce_admins                  = local.extension.enforce_admins
  required_pull_request_reviews   = local.extension.required_pull_request_reviews
  required_status_checks_contexts = local.extension.required_status_checks_contexts
  patterns                        = local.extension.patterns
  collaborator                    = local.extension.collaborator
}

module "sanctions" {
  source                          = "./modules/github-repository"
  name                            = "Sanctions"
  description                     = "🙅 Offers convenient way to handle sanctions."
  homepage_url                    = "https://www.mediawiki.org/wiki/Special:MyLanguage/Extension:Sanctions"
  topics                          = local.extension.topics
  enforce_admins                  = local.extension.enforce_admins
  required_pull_request_reviews   = local.extension.required_pull_request_reviews
  required_status_checks_contexts = local.extension.required_status_checks_contexts
  patterns                        = local.extension.patterns
  collaborator                    = local.extension.collaborator
}

module "achievement_badges" {
  source                          = "./modules/github-repository"
  name                            = "AchievementBadges"
  description                     = ":1st_place_medal: Provides an achievement system"
  homepage_url                    = "https://www.mediawiki.org/wiki/Special:MyLanguage/Extension:AchievementBadges"
  topics                          = local.extension.topics
  enforce_admins                  = local.extension.enforce_admins
  required_pull_request_reviews   = local.extension.required_pull_request_reviews
  required_status_checks_contexts = local.extension.required_status_checks_contexts
  patterns                        = local.extension.patterns
  collaborator                    = local.extension.collaborator
}

module "page_view_info_ga" {
  source                          = "./modules/github-repository"
  name                            = "PageViewInfoGA"
  description                     = "📈 Implements PageViewService for GoogleAnalytics"
  homepage_url                    = "https://www.mediawiki.org/wiki/Special:MyLanguage/Extension:PageViewInfoGA"
  topics                          = concat(local.extension.topics, ["google-analytics"])
  enforce_admins                  = local.extension.enforce_admins
  required_pull_request_reviews   = local.extension.required_pull_request_reviews
  required_status_checks_contexts = local.extension.required_status_checks_contexts
  patterns                        = local.extension.patterns
  collaborator                    = local.extension.collaborator
}

module "discord_rc_feed" {
  source                          = "./modules/github-repository"
  name                            = "DiscordRCFeed"
  description                     = "🎮 Provides MediaWiki's FormattedRCFeed and RCFeedFormatter for Discord"
  homepage_url                    = "https://www.mediawiki.org/wiki/Special:MyLanguage/Extension:DiscordRCFeed"
  topics                          = concat(local.extension.topics, ["discord"])
  enforce_admins                  = local.extension.enforce_admins
  required_pull_request_reviews   = local.extension.required_pull_request_reviews
  required_status_checks_contexts = local.extension.required_status_checks_contexts
  patterns                        = local.extension.patterns
  collaborator                    = local.extension.collaborator
}
