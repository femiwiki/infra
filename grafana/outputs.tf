output "public_dashboards" {
  description = "The externally shared boards, as their readers reach them"
  value = merge(local.public_dashboard_urls, {
    availability = "https://femiwiki.grafana.net/public-dashboards/${grafana_dashboard_public.availability.access_token}"
  })
}

output "github_io_prometheus" {
  description = "Where and how femiwiki.github.io reads the metrics"
  sensitive   = true
  value = {
    url   = data.grafana_cloud_stack.femiwiki.prometheus_url
    user  = data.grafana_cloud_stack.femiwiki.prometheus_user_id
    token = grafana_cloud_access_policy_token.github_io.token
  }
}
