resource "google_project_service" "analyticsdata" {
  service            = "analyticsdata.googleapis.com"
  disable_on_destroy = false
}

# Viewer on GA4 property 258014701 is granted in Google Analytics, not here
resource "google_service_account" "pageviewinfoga" {
  account_id   = "pageviewinfoga"
  display_name = "PageViewInfoGA"
  description  = "Reads femiwiki.com page views from the Google Analytics Data API"
}

resource "google_service_account_key" "pageviewinfoga" {
  service_account_id = google_service_account.pageviewinfoga.name
}
