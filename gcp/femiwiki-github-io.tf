# The availability page on femiwiki.github.io reads sessions per hour, from its main branch only.
# Viewer on GA4 property 258014701 is granted in Google Analytics, not here
resource "google_service_account" "femiwiki_github_io" {
  account_id   = "femiwiki-github-io"
  display_name = "femiwiki.github.io"
  description  = "Reads femiwiki.com sessions per hour from the Google Analytics Data API for the availability page"
}

resource "google_iam_workload_identity_pool_provider" "femiwiki_github_io" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = "femiwiki-github-io"
  attribute_condition                = "assertion.repository_id == '1377892969' && assertion.repository_owner_id == '21275875'"
  attribute_mapping = {
    "google.subject" = "assertion.sub"
  }

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

resource "google_service_account_iam_member" "femiwiki_github_io" {
  service_account_id = google_service_account.femiwiki_github_io.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principal://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/subject/repo:femiwiki@21275875/femiwiki.github.io@1377892969:ref:refs/heads/main"
}
