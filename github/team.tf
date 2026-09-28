resource "github_team" "reviewer" {
  name        = "Reviewer"
  description = "People reviewing PRs"
  privacy     = "closed"
}

resource "github_team" "package_manager" {
  name        = "Package Manager"
  description = "People managing Github Packages and Github Container Registry"
  privacy     = "closed"
}

# Required reviewers of infra's environments, so a member's approval is what
# starts an apply
resource "github_team" "deployer" {
  name        = "Deployer"
  description = "People approving infra applies"
  privacy     = "closed"
}

resource "github_team_membership" "deployer" {
  for_each = toset(["lens0021"])

  team_id  = github_team.deployer.id
  username = each.key
  role     = "maintainer"
}

# A reviewer needs read access to the repository
resource "github_team_repository" "deployer_infra" {
  team_id    = github_team.deployer.id
  repository = module.infra.name
  permission = "pull"
}
