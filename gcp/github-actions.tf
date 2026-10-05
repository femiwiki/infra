locals {
  github_actions_services = toset([
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "serviceusage.googleapis.com",
    "sts.googleapis.com",
  ])
}

resource "google_project_service" "github_actions" {
  for_each = local.github_actions_services

  service            = each.key
  disable_on_destroy = false
}

resource "google_iam_workload_identity_pool" "github" {
  workload_identity_pool_id = "github"
  display_name              = "GitHub Actions"
}

resource "google_iam_workload_identity_pool_provider" "infra" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = "femiwiki-infra"
  attribute_condition                = "assertion.repository_id == '188597503' && assertion.repository_owner_id == '21275875'"
  attribute_mapping = {
    "google.subject"                = "assertion.sub"
    "attribute.repository_id"       = "assertion.repository_id"
    "attribute.repository_owner_id" = "assertion.repository_owner_id"
  }

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

locals {
  github_actions = {
    infra-gcp-plan = {
      display_name = "femiwiki/infra plan"
      subject      = "repo:femiwiki@21275875/infra@188597503:pull_request"
      roles        = ["roles/iam.securityReviewer", "roles/viewer"]
    }
    infra-gcp = {
      display_name = "femiwiki/infra apply"
      subject      = "repo:femiwiki@21275875/infra@188597503:environment:gcp"
      roles = [
        "roles/iam.serviceAccountAdmin",
        "roles/iam.serviceAccountKeyAdmin",
        "roles/iam.workloadIdentityPoolAdmin",
        "roles/resourcemanager.projectIamAdmin",
        "roles/serviceusage.serviceUsageAdmin",
      ]
    }
  }

  github_actions_roles = merge([
    for name, account in local.github_actions : {
      for role in account.roles : "${name} ${role}" => { account = name, role = role }
    }
  ]...)
}

resource "google_service_account" "github_actions" {
  for_each = local.github_actions

  account_id   = each.key
  display_name = each.value.display_name
}

resource "google_project_iam_member" "github_actions" {
  for_each = local.github_actions_roles

  project = local.project
  role    = each.value.role
  member  = google_service_account.github_actions[each.value.account].member
}

resource "google_service_account_iam_member" "github_actions" {
  for_each = local.github_actions

  service_account_id = google_service_account.github_actions[each.key].name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principal://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/subject/${each.value.subject}"
}
