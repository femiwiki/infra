terraform {
  required_version = "~> 1.10"

  backend "s3" {
    bucket       = "tfstate-302617221463-ap-northeast-1-an"
    key          = "grafana/terraform.tfstate"
    region       = "ap-northeast-1"
    use_lockfile = true
  }

  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "~> 4.46"
    }
  }
}

provider "grafana" {
  url  = "https://femiwiki.grafana.net"
  auth = var.grafana_auth

  retries            = 5
  retry_wait         = 3
  retry_status_codes = ["403", "429", "5xx"]
}
