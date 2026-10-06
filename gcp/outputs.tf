output "pageviewinfoga_audience" {
  description = "The audience of PageViewInfoGA's credential configuration, which aws/ allows the Femiwiki role to request"
  value       = "//iam.googleapis.com/${google_iam_workload_identity_pool_provider.femiwiki.name}"
}

output "pageviewinfoga_impersonation_url" {
  description = "The service_account_impersonation_url of PageViewInfoGA's credential configuration"
  value       = "https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/${google_service_account.pageviewinfoga.email}:generateAccessToken"
}
