resource "github_repository" "repository" {
  name                   = var.name
  description            = var.description
  homepage_url           = var.homepage_url
  has_issues             = true
  allow_auto_merge       = true
  delete_branch_on_merge = var.delete_branch_on_merge
  auto_init              = true
  archive_on_destroy     = true
  topics                 = var.topics
  vulnerability_alerts   = true
  has_discussions        = false
}

resource "github_branch" "main_branch" {
  repository = github_repository.repository.name
  branch     = "main"
}

resource "github_branch_default" "branch_default" {
  repository = github_repository.repository.name
  branch     = github_branch.main_branch.branch
}

resource "github_branch_protection" "branch_protection" {
  count             = length(var.patterns)
  repository_id     = github_repository.repository.node_id
  pattern           = var.patterns[count.index]
  enforce_admins    = var.enforce_admins

  dynamic "required_status_checks" {
    for_each = var.required_status_checks_contexts
    content {
      strict   = true
      contexts = required_status_checks.value
    }
  }

  dynamic "required_pull_request_reviews" {
    for_each = var.required_pull_request_reviews
    content {
      dismiss_stale_reviews           = required_pull_request_reviews.value["dismiss_stale_reviews"]
      require_code_owner_reviews      = required_pull_request_reviews.value["require_code_owner_reviews"]
      required_approving_review_count = required_pull_request_reviews.value["required_approving_review_count"]
    }
  }
}

resource "github_team_repository" "team_repository" {
  repository = github_repository.repository.name
  team_id    = "3688706"
}

# Give push access to @translatewiki https://github.com/femiwiki/femiwiki/issues/91
resource "github_repository_collaborator" "repository_collaborator" {
  count      = var.collaborator ? 1 : 0
  repository = github_repository.repository.name
  username   = "translatewiki"
  permission = "push"
}
