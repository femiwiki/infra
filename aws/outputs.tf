output "grafana_github_url" {
  description = "Where Grafana's GitHub issue contact point posts"
  value       = aws_lambda_function_url.grafana_github.function_url
}

output "rate_limit_bucket" {
  description = "Where Caddy shares its rate limit counters"
  value       = module.rate_limit.s3_bucket_id
}

output "rate_limit_s3_host" {
  description = "The S3 endpoint of the rate limit bucket's region"
  value       = "s3.${module.rate_limit.s3_bucket_region}.amazonaws.com"
}

output "caddy_certs_bucket" {
  description = "Where Caddy keeps its ACME account and certificates"
  value       = module.caddy_certs.s3_bucket_id
}

output "caddy_certs_s3_host" {
  description = "The S3 endpoint of the Caddy certificates bucket's region"
  value       = "s3.${module.caddy_certs.s3_bucket_region}.amazonaws.com"
}

output "chart_renderer_url" {
  description = "The function URL MediaWiki's Chart extension posts to, followed by a token"
  value       = module.chart_renderer.url
}

output "outbound_issuer" {
  description = "The issuer of the JWTs that sts:GetWebIdentityToken signs for this account"
  value       = aws_iam_outbound_web_identity_federation.this.issuer_identifier
}

output "database_address" {
  description = "The address the primary database answers at, whichever host holds it"
  value       = one(aws_network_interface.database.private_ips)
}

output "femiwiki_role_arn" {
  description = "The role of the wiki's instances"
  value       = module.femiwiki.arn
}

output "roles_anywhere_ca_cert_pem" {
  description = "The CA certificate that the IAM Roles Anywhere trust anchor trusts"
  value       = tls_self_signed_cert.roles_anywhere_ca.cert_pem
}

output "roles_anywhere_ca_private_key_pem" {
  description = "The key that signs the containers' IAM Roles Anywhere certificates"
  value       = tls_private_key.roles_anywhere_ca.private_key_pem
  sensitive   = true
}

output "roles_anywhere_trust_anchor_arn" {
  description = "The IAM Roles Anywhere trust anchor of the containers' certificates"
  value       = aws_rolesanywhere_trust_anchor.femiwiki.arn
}

output "roles_anywhere_profile_arn" {
  description = "The IAM Roles Anywhere profile the containers' sessions come from"
  value       = aws_rolesanywhere_profile.femiwiki.arn
}

output "caddy_role_arn" {
  description = "The role of Caddy's container, through IAM Roles Anywhere"
  value       = module.caddy.arn
}

output "mediawiki_role_arn" {
  description = "The role of MediaWiki's containers, through IAM Roles Anywhere"
  value       = module.mediawiki.arn
}
