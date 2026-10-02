output "public_dashboards" {
  description = "The externally shared boards, as their readers reach them"
  value = merge(local.public_dashboard_urls, {
    availability = "https://femiwiki.grafana.net/public-dashboards/${grafana_dashboard_public.availability.access_token}"
  })
}
