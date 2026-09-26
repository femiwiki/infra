resource "grafana_folder" "hosts" {
  title = "Hosts"
}

data "grafana_folder" "femiwiki" {
  title = "Femiwiki"
}
