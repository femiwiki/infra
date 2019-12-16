locals {
  github_organization = "femiwiki"
  github_admins = [
    "femiwiki-bot",
    "lens0021",
    "simnalamburt",
  ]
  github_members = [
    "765P",
    "choidamdam",
    "HanbitGaram",
    "vvvvviral",
  ]
}

resource "github_membership" "admins" {
  for_each = toset(local.github_admins)

  username = each.key
  role     = "admin"
}

resource "github_membership" "members" {
  for_each = toset(local.github_members)

  username = each.key
  role     = "member"
}
