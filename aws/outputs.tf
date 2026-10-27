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
