terraform {
  required_version = "~> 1.10"

  backend "s3" {
    bucket       = "tfstate-302617221463-ap-northeast-1-an"
    key          = "gcp/terraform.tfstate"
    region       = "ap-northeast-1"
    use_lockfile = true
  }

  # aws reads this state, and the key provider's name is recorded in it, so it
  # must not be "state", which aws uses for its own. Never rename "gcp".
  encryption {
    key_provider "pbkdf2" "gcp" {
      passphrase = var.state_passphrase
    }

    method "aes_gcm" "gcp" {
      keys = key_provider.pbkdf2.gcp
    }

    key_provider "pbkdf2" "state" {
      passphrase = var.state_passphrase
    }

    method "aes_gcm" "state" {
      keys = key_provider.pbkdf2.state
    }

    state {
      method   = method.aes_gcm.gcp
      enforced = true

      fallback {
        method = method.aes_gcm.state
      }
    }

    plan {
      method   = method.aes_gcm.gcp
      enforced = true
    }
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 8.5"
    }
  }
}

provider "google" {
  project = local.project
}

locals {
  project = "femiwiki-b2dad"
}
