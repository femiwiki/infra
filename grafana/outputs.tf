output "public_dashboards" {
  description = "The externally shared boards, as their readers reach them"
  value = {
    for name, board in grafana_dashboard_public.this :
    name => "https://femiwiki.grafana.net/public-dashboards/${board.access_token}"
  }
}
