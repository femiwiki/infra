variable "oauth_token_id" {
  type = string
}

resource "tfe_oauth_client" "github" {
  organization     = "femiwiki"
  api_url          = "https://api.github.com"
  http_url         = "https://github.com"
  oauth_token      = var.oauth_token_id
  service_provider = "github"
}
