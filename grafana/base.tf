terraform {
  required_version = "~> 1.10"

  backend "s3" {
    bucket       = "tfstate-302617221463-ap-northeast-1-an"
    key          = "grafana/terraform.tfstate"
    region       = "ap-northeast-1"
    use_lockfile = true
  }

  # Only to read the aws outputs; this state itself stays unencrypted.
  encryption {
    # Same names as in aws/base.tf, which the stored key metadata is filed under.
    key_provider "pbkdf2" "state" {
      passphrase = var.aws_state_passphrase
    }

    method "aes_gcm" "state" {
      keys = key_provider.pbkdf2.state
    }

    remote_state_data_sources {
      remote_state_data_source "aws" {
        method = method.aes_gcm.state
      }
    }
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

data "terraform_remote_state" "aws" {
  backend = "s3"

  config = {
    bucket = "tfstate-302617221463-ap-northeast-1-an"
    key    = "aws/terraform.tfstate"
    region = "ap-northeast-1"
  }
}
