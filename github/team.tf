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
