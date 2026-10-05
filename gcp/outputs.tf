output "pageviewinfoga_credentials" {
  description = "The JSON key of the PageViewInfoGA service account, which aws writes to SSM."
  value       = base64decode(google_service_account_key.pageviewinfoga.private_key)
  sensitive   = true
}
