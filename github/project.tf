resource "github_organization_project" "dev" {
  name = "개발"
  body = ":shipit: 페미위키 관련된 기술적인 사안"
}

resource "github_project_column" "columns" {
  for_each = toset([
    "To do",
    "In Progress",
    "Blocked",
    "Workaround",
    "Done",
  ])

  project_id = github_organization_project.dev.id
  name       = each.key
}
