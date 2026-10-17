terraform {
  required_version = "1.13.1"

  backend "s3" {
    bucket       = "tfstate-302617221463-ap-northeast-2-an"
    key          = "healthchecks/terraform.tfstate"
    region       = "ap-northeast-2"
    use_lockfile = true
  }

  required_providers {
    healthchecksio = {
      source  = "kristofferahl/healthchecksio"
      version = "~> 2.3"
    }
  }
}

provider "healthchecksio" {
  api_key = var.healthchecksio_api_key
}
