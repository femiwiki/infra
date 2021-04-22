data "github_repositories" "actives" {
  query = "org:femiwiki archived:false fork:false"
}

resource "github_issue_label" "bug" {
  for_each    = toset(data.github_repositories.actives.names)
  repository  = each.key
  name        = "Bug"
  color       = "ee0701"
  description = ""
}

resource "github_issue_label" "dependencies" {
  for_each    = toset(data.github_repositories.actives.names)
  repository  = each.key
  name        = "dependencies"
  color       = "a7f42c"
  description = "Pull requests that update a dependency file"
}

resource "github_issue_label" "enhancement" {
  for_each    = toset(data.github_repositories.actives.names)
  repository  = each.key
  name        = "enhancement"
  color       = "a2eeef"
  description = "New feature or request"
}

resource "github_issue_label" "epic" {
  for_each    = toset(data.github_repositories.actives.names)
  repository  = each.key
  name        = "EPIC"
  color       = "fc7a6c"
  description = ""
}

resource "github_issue_label" "femiwki_discussion_needed" {
  for_each    = toset(data.github_repositories.actives.names)
  repository  = each.key
  name        = "femiwki discussion needed"
  color       = "d4c5f9"
  description = ""
}

resource "github_issue_label" "invalid" {
  for_each    = toset(data.github_repositories.actives.names)
  repository  = each.key
  name        = "invalid"
  color       = "e4e669"
  description = "This doesn't seem right"
}

resource "github_issue_label" "wontfix" {
  for_each    = toset(data.github_repositories.actives.names)
  repository  = each.key
  name        = "wontfix"
  color       = "ffffff"
  description = "This will not be worked on"
}

resource "github_issue_label" "note" {
  for_each    = toset(data.github_repositories.actives.names)
  repository  = each.key
  name        = "글쓰기"
  color       = "0075ca"
  description = "공지사항이나 블로그 글로 문서화해야하는 이슈"
}

resource "github_issue_label" "operation" {
  for_each    = toset(data.github_repositories.actives.names)
  repository  = each.key
  name        = "Operation"
  color       = "85d659"
  description = "점검, 인프라 작업"
}

resource "github_issue_label" "REL1_35" {
  for_each    = toset(data.github_repositories.actives.names)
  repository  = each.key
  name        = "MW1.35"
  color       = "5319e7"
  description = "MediaWiki 1.35"
}
