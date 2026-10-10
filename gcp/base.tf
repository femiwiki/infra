terraform {
  required_version = "1.13.1"

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

    # Same names as in aws/base.tf, which the aws state's key metadata is filed under
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

    state {
      method   = method.aes_gcm.gcp
      enforced = true
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

data "terraform_remote_state" "aws" {
  backend = "s3"

  config = {
    bucket = "tfstate-302617221463-ap-northeast-1-an"
    key    = "aws/terraform.tfstate"
    region = "ap-northeast-1"
  }
}
