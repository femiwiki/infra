resource "github_repository" "repository" {
  name                 = var.name
  description          = var.description
  has_issues           = true
  vulnerability_alerts = true
  topics               = var.topics
  archive_on_destroy   = true
  auto_init            = true
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
  push_restrictions = []

  dynamic "required_pull_request_reviews" {
    for_each = var.required_pull_request_reviews
    content {
      dismiss_stale_reviews           = required_pull_request_reviews.value["dismiss_stale_reviews"]
      require_code_owner_reviews      = required_pull_request_reviews.value["require_code_owner_reviews"]
      required_approving_review_count = required_pull_request_reviews.value["required_approving_review_count"]
    }
  }
}

# Bug: https://github.com/integrations/terraform-provider-github/issues/769
# resource "github_team_repository" "team_repository" {
#   repository = github_repository.repository.name
#   team_id    = "3688706"
# }
