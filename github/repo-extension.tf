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
}

#
# skin
#
resource "github_repository" "femiwiki_skin" {
  name                 = "FemiwikiSkin"
  description          = ":jack_o_lantern: 페미위키 스킨"
  homepage_url         = "https://www.mediawiki.org/wiki/Special:MyLanguage/Skin:Femiwiki"
  has_issues           = local.skin.has_issues
  vulnerability_alerts = local.skin.vulnerability_alerts
  archive_on_destroy   = local.skin.archive_on_destroy
  topics               = local.skin.topics
}

resource "github_branch_protection" "femiwiki_skin" {
  repository_id     = github_repository.femiwiki_skin.node_id
  pattern           = "master"
  enforce_admins    = local.skin.enforce_admins
  push_restrictions = local.skin.push_restrictions

  required_pull_request_reviews {
    dismiss_stale_reviews           = local.skin.dismiss_stale_reviews
    require_code_owner_reviews      = local.skin.require_code_owner_reviews
    required_approving_review_count = local.skin.required_approving_review_count
  }
}

resource "github_branch_protection" "femiwiki_skin_REL" {
  repository_id     = github_repository.femiwiki_skin.node_id
  pattern           = "REL*"
  enforce_admins    = local.skin.enforce_admins
  push_restrictions = local.skin.push_restrictions

  required_pull_request_reviews {
    dismiss_stale_reviews           = local.skin.dismiss_stale_reviews
    require_code_owner_reviews      = local.skin.require_code_owner_reviews
    required_approving_review_count = local.skin.required_approving_review_count
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

resource "github_branch_protection" "unified_extension_for_femiwiki" {
  repository_id     = github_repository.unified_extension_for_femiwiki.node_id
  pattern           = "master"
  enforce_admins    = local.extension.enforce_admins
  push_restrictions = local.extension.push_restrictions

  required_pull_request_reviews {
    dismiss_stale_reviews           = local.extension.dismiss_stale_reviews
    require_code_owner_reviews      = local.extension.require_code_owner_reviews
    required_approving_review_count = local.extension.required_approving_review_count
  }
}

resource "github_branch_protection" "unified_extension_for_femiwiki_REL" {
  repository_id     = github_repository.unified_extension_for_femiwiki.node_id
  pattern           = "REL*"
  enforce_admins    = local.extension.enforce_admins
  push_restrictions = local.extension.push_restrictions

  required_pull_request_reviews {
    dismiss_stale_reviews           = local.extension.dismiss_stale_reviews
    require_code_owner_reviews      = local.extension.require_code_owner_reviews
    required_approving_review_count = local.extension.required_approving_review_count
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

resource "github_branch_protection" "faceted_category" {
  repository_id     = github_repository.faceted_category.node_id
  pattern           = "master"
  enforce_admins    = local.extension.enforce_admins
  push_restrictions = local.extension.push_restrictions

  required_pull_request_reviews {
    dismiss_stale_reviews           = local.extension.dismiss_stale_reviews
    require_code_owner_reviews      = local.extension.require_code_owner_reviews
    required_approving_review_count = local.extension.required_approving_review_count
  }
}

resource "github_branch_protection" "faceted_category_REL" {
  repository_id     = github_repository.faceted_category.node_id
  pattern           = "REL*"
  enforce_admins    = local.extension.enforce_admins
  push_restrictions = local.extension.push_restrictions

  required_pull_request_reviews {
    dismiss_stale_reviews           = local.extension.dismiss_stale_reviews
    require_code_owner_reviews      = local.extension.require_code_owner_reviews
    required_approving_review_count = local.extension.required_approving_review_count
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

resource "github_repository" "category_intersection_search" {
  name                 = "CategoryIntersectionSearch"
  description          = "provide special page show category intersection"
  homepage_url         = "https://www.mediawiki.org/wiki/Special:MyLanguage/Extension:CategoryIntersectionSearch"
  has_issues           = local.extension.has_issues
  vulnerability_alerts = local.extension.vulnerability_alerts
  archive_on_destroy   = local.extension.archive_on_destroy
  topics               = local.extension.topics
}

resource "github_branch_protection" "category_intersection_search" {
  repository_id     = github_repository.category_intersection_search.node_id
  pattern           = "master"
  enforce_admins    = local.extension.enforce_admins
  push_restrictions = local.extension.push_restrictions

  required_pull_request_reviews {
    dismiss_stale_reviews           = local.extension.dismiss_stale_reviews
    require_code_owner_reviews      = local.extension.require_code_owner_reviews
    required_approving_review_count = local.extension.required_approving_review_count
  }
}

resource "github_branch_protection" "category_intersection_search_REL" {
  repository_id     = github_repository.category_intersection_search.node_id
  pattern           = "REL*"
  enforce_admins    = local.extension.enforce_admins
  push_restrictions = local.extension.push_restrictions

  required_pull_request_reviews {
    dismiss_stale_reviews           = local.extension.dismiss_stale_reviews
    require_code_owner_reviews      = local.extension.require_code_owner_reviews
    required_approving_review_count = local.extension.required_approving_review_count
  }
}

resource "github_team_repository" "category_intersection_search" {
  team_id    = github_team.reviewer.id
  repository = github_repository.category_intersection_search.name
}

# Give push access to @translatewiki https://github.com/femiwiki/femiwiki/issues/91
resource "github_repository_collaborator" "category_intersection_search" {
  repository = github_repository.category_intersection_search.name
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

resource "github_branch_protection" "sanctions" {
  repository_id     = github_repository.sanctions.node_id
  pattern           = "master"
  enforce_admins    = local.extension.enforce_admins
  push_restrictions = local.extension.push_restrictions

  required_pull_request_reviews {
    dismiss_stale_reviews           = local.extension.dismiss_stale_reviews
    require_code_owner_reviews      = local.extension.require_code_owner_reviews
    required_approving_review_count = local.extension.required_approving_review_count
  }
}

resource "github_branch_protection" "sanctions_REL" {
  repository_id     = github_repository.sanctions.node_id
  pattern           = "REL*"
  enforce_admins    = local.extension.enforce_admins
  push_restrictions = local.extension.push_restrictions

  required_pull_request_reviews {
    dismiss_stale_reviews           = local.extension.dismiss_stale_reviews
    require_code_owner_reviews      = local.extension.require_code_owner_reviews
    required_approving_review_count = local.extension.required_approving_review_count
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
  description          = "TBD"
  homepage_url         = "https://www.mediawiki.org/wiki/Special:MyLanguage/Extension:AchievementBadges"
  has_issues           = local.extension.has_issues
  vulnerability_alerts = local.extension.vulnerability_alerts
  archive_on_destroy   = local.extension.archive_on_destroy
  topics               = local.extension.topics
}

resource "github_branch_protection" "achievement_badges" {
  repository_id     = github_repository.achievement_badges.node_id
  pattern           = "master"
  enforce_admins    = local.extension.enforce_admins
  push_restrictions = local.extension.push_restrictions

  required_pull_request_reviews {
    dismiss_stale_reviews           = local.extension.dismiss_stale_reviews
    require_code_owner_reviews      = local.extension.require_code_owner_reviews
    required_approving_review_count = local.extension.required_approving_review_count
  }
}

resource "github_branch_protection" "achievement_badges_REL" {
  repository_id     = github_repository.achievement_badges.node_id
  pattern           = "REL*"
  enforce_admins    = local.extension.enforce_admins
  push_restrictions = local.extension.push_restrictions

  required_pull_request_reviews {
    dismiss_stale_reviews           = local.extension.dismiss_stale_reviews
    require_code_owner_reviews      = local.extension.require_code_owner_reviews
    required_approving_review_count = local.extension.required_approving_review_count
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
