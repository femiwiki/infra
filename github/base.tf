terraform {
  required_version = "1.13.2"

  backend "s3" {
    bucket       = "tfstate-302617221463-ap-northeast-2-an"
    key          = "github/terraform.tfstate"
    region       = "ap-northeast-2"
    use_lockfile = true
  }

  # Encrypted before the root writes Actions secrets (#983). Never rename the
  # key provider or a method: the encrypted state records their names.
  encryption {
    key_provider "pbkdf2" "state" {
      passphrase = var.state_passphrase
    }

    method "aes_gcm" "state" {
      keys = key_provider.pbkdf2.state
    }

    # Same names as in grafana/base.tf, which the stored key metadata is filed under
    key_provider "pbkdf2" "grafana" {
      passphrase = var.grafana_state_passphrase
    }

    method "aes_gcm" "grafana" {
      keys = key_provider.pbkdf2.grafana
    }

    remote_state_data_sources {
      remote_state_data_source "grafana" {
        method = method.aes_gcm.grafana
      }
    }

    state {
      method   = method.aes_gcm.state
      enforced = true
    }

    plan {
      method   = method.aes_gcm.state
      enforced = true
    }
  }

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
    onepassword = {
      source  = "1Password/onepassword"
      version = "~> 3.3"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7"
    }
  }
}

provider "github" {
  owner = "femiwiki"
  token = var.github_token

  # The legacy client sends one request at a time, which is most of the plan
  legacy_client = false
}

data "terraform_remote_state" "grafana" {
  backend = "s3"

  config = {
    bucket = "tfstate-302617221463-ap-northeast-2-an"
    key    = "grafana/terraform.tfstate"
    region = "ap-northeast-2"
  }
}

# Reads OP_SERVICE_ACCOUNT_TOKEN, a service account that can only read the infra vault.
provider "onepassword" {}
