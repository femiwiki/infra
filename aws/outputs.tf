output "ssm_parameters_mysql" {
  value     = data.aws_ssm_parameters_by_path.mysql
  sensitive = true
}

output "ssm_parameters_mediawiki" {
  value     = data.aws_ssm_parameters_by_path.mediawiki
  sensitive = true
}


output "grafana_github_url" {
  description = "Where Grafana's GitHub issue contact point posts"
  value       = aws_lambda_function_url.grafana_github.function_url
}
