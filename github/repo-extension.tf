locals {
  skin = merge(local.default_repo, {
    topics = [
      "mediawiki-skin",
    ],
  })
  # local.default_repo is defined in repo.tf
  extension = merge(local.default_repo, {
    topics = [
      "mediawiki-extension",
    ],
  })
  extension_branches = [
    # Cannot protect translatable branches now.
    # See https://phabricator.wikimedia.org/T235938#5592510 for detail.
    # "main",
    "REL*_*"
  ]
}

#
# skin
#
resource "github_repository" "femiwiki_skin" {
  name                 = "FemiwikiSkin"
  description          = ":jack_o_lantern: FemiwikiSkin"
  homepage_url         = "https://www.mediawiki.org/wiki/Special:MyLanguage/Skin:Femiwiki"
  has_issues           = local.skin.has_issues
  vulnerability_alerts = local.skin.vulnerability_alerts
  archive_on_destroy   = local.skin.archive_on_destroy
  topics               = local.skin.topics
}

resource "github_branch" "femiwiki_skin_main" {
  repository = github_repository.femiwiki_skin.name
  branch     = "main"
}

resource "github_branch_default" "femiwiki_skin" {
  repository = github_repository.femiwiki_skin.name
  branch     = github_branch.femiwiki_skin_main.branch
}

resource "github_branch_protection" "femiwiki_skin" {
  count             = length(local.extension_branches)
  repository_id     = github_repository.femiwiki_skin.node_id
  pattern           = local.extension_branches[count.index]
  enforce_admins    = local.skin.enforce_admins
  push_restrictions = local.skin.push_restrictions

  dynamic "required_pull_request_reviews" {
    for_each = local.skin.required_pull_request_reviews
    content {
      dismiss_stale_reviews           = required_pull_request_reviews.value["dismiss_stale_reviews"]
      require_code_owner_reviews      = required_pull_request_reviews.value["require_code_owner_reviews"]
      required_approving_review_count = required_pull_request_reviews.value["required_approving_review_count"]
    }
  }
}

resource "github_team_repository" "femiwiki_skin" {
  team_id    = github_team.reviewer.id
  repository = github_repository.femiwiki_skin.name
}

# Give push access to @translatewiki https://github.com/femiwiki/femiwiki/issues/91
resource "github_repository_collaborator" "femiwiki_skin" {
  repository = github_repository.femiwiki_skin.name
  username   = "translatewiki"
  permission = "push"
}

#
# extensions
#
resource "github_repository" "unified_extension_for_femiwiki" {
  name                 = "UnifiedExtensionForFemiwiki"
  description          = "Unified Extension For Femiwiki"
  homepage_url         = "https://www.mediawiki.org/wiki/Special:MyLanguage/Extension:UnifiedExtensionForFemiwiki"
  has_issues           = local.extension.has_issues
  vulnerability_alerts = local.extension.vulnerability_alerts
  archive_on_destroy   = local.extension.archive_on_destroy
  topics               = local.extension.topics
}

resource "github_branch" "unified_extension_for_femiwiki_main" {
  repository = github_repository.unified_extension_for_femiwiki.name
  branch     = "main"
}

resource "github_branch_default" "unified_extension_for_femiwiki" {
  repository = github_repository.unified_extension_for_femiwiki.name
  branch     = github_branch.unified_extension_for_femiwiki_main.branch
}

resource "github_branch_protection" "unified_extension_for_femiwiki" {
  count             = length(local.extension_branches)
  repository_id     = github_repository.unified_extension_for_femiwiki.node_id
  pattern           = local.extension_branches[count.index]
  enforce_admins    = local.extension.enforce_admins
  push_restrictions = local.extension.push_restrictions

  dynamic "required_pull_request_reviews" {
    for_each = local.extension.required_pull_request_reviews
    content {
      dismiss_stale_reviews           = required_pull_request_reviews.value["dismiss_stale_reviews"]
      require_code_owner_reviews      = required_pull_request_reviews.value["require_code_owner_reviews"]
      required_approving_review_count = required_pull_request_reviews.value["required_approving_review_count"]
    }
  }
}

resource "github_team_repository" "unified_extension_for_femiwiki" {
  team_id    = github_team.reviewer.id
  repository = github_repository.unified_extension_for_femiwiki.name
}

# Give push access to @translatewiki https://github.com/femiwiki/femiwiki/issues/91
resource "github_repository_collaborator" "unified_extension_for_femiwiki" {
  repository = github_repository.unified_extension_for_femiwiki.name
  username   = "translatewiki"
  permission = "push"
}

resource "github_repository" "faceted_category" {
  name                 = "FacetedCategory"
  description          = "FacetedCategories extension"
  homepage_url         = "https://www.mediawiki.org/wiki/Special:MyLanguage/Extension:FacetedCategory"
  has_issues           = local.extension.has_issues
  vulnerability_alerts = local.extension.vulnerability_alerts
  archive_on_destroy   = local.extension.archive_on_destroy
  topics               = local.extension.topics
}

resource "github_branch" "faceted_category_main" {
  repository = github_repository.faceted_category.name
  branch     = "main"
}

resource "github_branch_default" "faceted_category" {
  repository = github_repository.faceted_category.name
  branch     = github_branch.faceted_category_main.branch
}

resource "github_branch_protection" "faceted_category" {
  count             = length(local.extension_branches)
  repository_id     = github_repository.faceted_category.node_id
  pattern           = local.extension_branches[count.index]
  enforce_admins    = local.extension.enforce_admins
  push_restrictions = local.extension.push_restrictions

  dynamic "required_pull_request_reviews" {
    for_each = local.with_cd.required_pull_request_reviews
    content {
      dismiss_stale_reviews           = required_pull_request_reviews.value["dismiss_stale_reviews"]
      require_code_owner_reviews      = required_pull_request_reviews.value["require_code_owner_reviews"]
      required_approving_review_count = required_pull_request_reviews.value["required_approving_review_count"]
    }
  }
}

resource "github_team_repository" "faceted_category" {
  team_id    = github_team.reviewer.id
  repository = github_repository.faceted_category.name
}

# Give push access to @translatewiki https://github.com/femiwiki/femiwiki/issues/91
resource "github_repository_collaborator" "faceted_category" {
  repository = github_repository.faceted_category.name
  username   = "translatewiki"
  permission = "push"
}

resource "github_repository" "sanctions" {
  name                 = "Sanctions"
  description          = "🙅 Offers convenient way to handle sanctions."
  homepage_url         = "https://www.mediawiki.org/wiki/Special:MyLanguage/Extension:Sanctions"
  has_issues           = local.extension.has_issues
  vulnerability_alerts = local.extension.vulnerability_alerts
  archive_on_destroy   = local.extension.archive_on_destroy
  topics               = local.extension.topics
}

resource "github_branch" "sanctions_main" {
  repository = github_repository.sanctions.name
  branch     = "main"
}

resource "github_branch_default" "sanctions" {
  repository = github_repository.sanctions.name
  branch     = github_branch.sanctions_main.branch
}

resource "github_branch_protection" "sanctions" {
  count             = length(local.extension_branches)
  repository_id     = github_repository.sanctions.node_id
  pattern           = local.extension_branches[count.index]
  enforce_admins    = local.extension.enforce_admins
  push_restrictions = local.extension.push_restrictions

  dynamic "required_pull_request_reviews" {
    for_each = local.with_cd.required_pull_request_reviews
    content {
      dismiss_stale_reviews           = required_pull_request_reviews.value["dismiss_stale_reviews"]
      require_code_owner_reviews      = required_pull_request_reviews.value["require_code_owner_reviews"]
      required_approving_review_count = required_pull_request_reviews.value["required_approving_review_count"]
    }
  }
}

resource "github_team_repository" "sanctions" {
  team_id    = github_team.reviewer.id
  repository = github_repository.sanctions.name
}

# Give push access to @translatewiki https://github.com/femiwiki/femiwiki/issues/91
resource "github_repository_collaborator" "sanctions" {
  repository = github_repository.sanctions.name
  username   = "translatewiki"
  permission = "push"
}

resource "github_repository" "achievement_badges" {
  name                 = "AchievementBadges"
  description          = ":1st_place_medal: Provides an achievement system"
  homepage_url         = "https://www.mediawiki.org/wiki/Special:MyLanguage/Extension:AchievementBadges"
  has_issues           = local.extension.has_issues
  vulnerability_alerts = local.extension.vulnerability_alerts
  archive_on_destroy   = local.extension.archive_on_destroy
  topics               = local.extension.topics
}

resource "github_branch" "achievement_badges_main" {
  repository = github_repository.achievement_badges.name
  branch     = "main"
}

resource "github_branch_default" "achievement_badges" {
  repository = github_repository.achievement_badges.name
  branch     = github_branch.achievement_badges_main.branch
}

resource "github_branch_protection" "achievement_badges" {
  count             = length(local.extension_branches)
  repository_id     = github_repository.achievement_badges.node_id
  pattern           = local.extension_branches[count.index]
  enforce_admins    = local.extension.enforce_admins
  push_restrictions = local.extension.push_restrictions

  dynamic "required_pull_request_reviews" {
    for_each = local.with_cd.required_pull_request_reviews
    content {
      dismiss_stale_reviews           = required_pull_request_reviews.value["dismiss_stale_reviews"]
      require_code_owner_reviews      = required_pull_request_reviews.value["require_code_owner_reviews"]
      required_approving_review_count = required_pull_request_reviews.value["required_approving_review_count"]
    }
  }
}

resource "github_team_repository" "achievement_badges" {
  team_id    = github_team.reviewer.id
  repository = github_repository.achievement_badges.name
}

# Give push access to @translatewiki https://github.com/femiwiki/femiwiki/issues/91
resource "github_repository_collaborator" "achievement_badges" {
  repository = github_repository.achievement_badges.name
  username   = "translatewiki"
  permission = "push"
}

resource "github_repository" "page_view_info_ga" {
  name                 = "PageViewInfoGA"
  description          = "📈 Implements PageViewService for GoogleAnalytics"
  homepage_url         = "https://www.mediawiki.org/wiki/Special:MyLanguage/Extension:PageViewInfoGA"
  has_issues           = local.extension.has_issues
  vulnerability_alerts = local.extension.vulnerability_alerts
  archive_on_destroy   = local.extension.archive_on_destroy
  topics               = concat(local.extension.topics, ["google-analytics"])
}

resource "github_branch" "page_view_info_ga_main" {
  repository = github_repository.page_view_info_ga.name
  branch     = "main"
}

resource "github_branch_default" "page_view_info_ga" {
  repository = github_repository.page_view_info_ga.name
  branch     = github_branch.page_view_info_ga_main.branch
}

resource "github_branch_protection" "page_view_info_ga" {
  count             = length(local.extension_branches)
  repository_id     = github_repository.page_view_info_ga.node_id
  pattern           = local.extension_branches[count.index]
  enforce_admins    = local.extension.enforce_admins
  push_restrictions = local.extension.push_restrictions

  dynamic "required_pull_request_reviews" {
    for_each = local.with_cd.required_pull_request_reviews
    content {
      dismiss_stale_reviews           = required_pull_request_reviews.value["dismiss_stale_reviews"]
      require_code_owner_reviews      = required_pull_request_reviews.value["require_code_owner_reviews"]
      required_approving_review_count = required_pull_request_reviews.value["required_approving_review_count"]
    }
  }
}

resource "github_team_repository" "page_view_info_ga" {
  team_id    = github_team.reviewer.id
  repository = github_repository.page_view_info_ga.name
}

# Give push access to @translatewiki https://github.com/femiwiki/femiwiki/issues/91
resource "github_repository_collaborator" "page_view_info_ga" {
  repository = github_repository.page_view_info_ga.name
  username   = "translatewiki"
  permission = "push"
}
