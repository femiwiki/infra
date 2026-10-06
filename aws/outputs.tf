output "grafana_github_url" {
  description = "Where Grafana's GitHub issue contact point posts"
  value       = aws_lambda_function_url.grafana_github.function_url
}

output "rate_limit_bucket" {
  description = "Where Caddy shares its rate limit counters"
  value       = aws_s3_bucket.rate_limit.bucket
}

output "rate_limit_s3_host" {
  description = "The S3 endpoint of the rate limit bucket's region"
  value       = "s3.${aws_s3_bucket.rate_limit.region}.amazonaws.com"
}

output "caddy_certs_bucket" {
  description = "Where Caddy keeps its ACME account and certificates"
  value       = aws_s3_bucket.caddy_certs.bucket
}

output "caddy_certs_s3_host" {
  description = "The S3 endpoint of the Caddy certificates bucket's region"
  value       = "s3.${aws_s3_bucket.caddy_certs.region}.amazonaws.com"
}

output "outbound_issuer" {
  description = "The issuer of the JWTs that sts:GetWebIdentityToken signs for this account"
  value       = aws_iam_outbound_web_identity_federation.this.issuer_identifier
}

output "femiwiki_role_arn" {
  description = "The role of the wiki's instances"
  value       = aws_iam_role.femiwiki.arn
}
