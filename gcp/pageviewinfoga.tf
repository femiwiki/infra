resource "google_project_service" "analyticsdata" {
  service            = "analyticsdata.googleapis.com"
  disable_on_destroy = false
}

# Viewer on GA4 property 258014701 is granted in Google Analytics, not here
resource "google_service_account" "pageviewinfoga" {
  account_id   = "pageviewinfoga"
  display_name = "PageViewInfoGA"
  description  = "Reads femiwiki.com page views from the Google Analytics Data API"
}

# A pool of its own, so no GitHub subject can ever name the Femiwiki role
resource "google_iam_workload_identity_pool" "aws_sts" {
  workload_identity_pool_id = "aws-sts"
  display_name              = "AWS"
}

resource "google_iam_workload_identity_pool_provider" "femiwiki" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.aws_sts.workload_identity_pool_id
  workload_identity_pool_provider_id = "femiwiki"
  attribute_condition                = "assertion.sub == '${data.terraform_remote_state.aws.outputs.femiwiki_role_arn}'"
  attribute_mapping = {
    "google.subject" = "assertion.sub"
  }

  oidc {
    issuer_uri = data.terraform_remote_state.aws.outputs.outbound_issuer
  }
}

resource "google_service_account_iam_member" "pageviewinfoga_femiwiki" {
  service_account_id = google_service_account.pageviewinfoga.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principal://iam.googleapis.com/${google_iam_workload_identity_pool.aws_sts.name}/subject/${data.terraform_remote_state.aws.outputs.femiwiki_role_arn}"
}

# The availability page on femiwiki.github.io reads sessions per hour, from its main branch only
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

resource "google_service_account_iam_member" "pageviewinfoga_femiwiki_github_io" {
  service_account_id = google_service_account.pageviewinfoga.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principal://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/subject/repo:femiwiki@21275875/femiwiki.github.io@1377892969:ref:refs/heads/main"
}
