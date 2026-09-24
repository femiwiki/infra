output "public_dashboards" {
  description = "The externally shared boards, as their readers reach them"
  value = {
    for name, board in {
      site             = grafana_dashboard_public.site
      availability     = grafana_dashboard_public.availability
      container_memory = grafana_dashboard_public.container_memory
    } :
    name => "https://femiwiki.grafana.net/public-dashboards/${board.access_token}"
  }
}
