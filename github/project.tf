resource "github_organization_project" "dev" {
  name = "femiwiki.com"
  body = ":shipit: 페미위키 관련된 기술적인 사안"
}

resource "github_project_column" "columns" {
  for_each = toset([
    "To do",
    "In Progress",
    "Blocked",
    "Workaround",
    "Done",
    "Declined",
  ])

  project_id = github_organization_project.dev.id
  name       = each.key
}
