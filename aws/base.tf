terraform {
  required_version = "1.13.1"

  backend "s3" {
    bucket       = "tfstate-302617221463-ap-northeast-1-an"
    key          = "aws/terraform.tfstate"
    region       = "ap-northeast-1"
    use_lockfile = true
  }

  # The state holds var.prometheus_password and var.loki_password, so it is
  # encrypted before it reaches the bucket. Never rename the key provider or the
  # method: the encrypted state records their names, and a renamed one cannot
  # read it back.
  encryption {
    key_provider "pbkdf2" "state" {
      passphrase = var.state_passphrase
    }

    method "aes_gcm" "state" {
      keys = key_provider.pbkdf2.state
    }

    key_provider "pbkdf2" "gcp" {
      passphrase = var.gcp_state_passphrase
    }

    method "aes_gcm" "gcp" {
      keys = key_provider.pbkdf2.gcp
    }

    remote_state_data_sources {
      remote_state_data_source "gcp" {
        method = method.aes_gcm.gcp
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
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.7"
    }
  }
}

provider "aws" {
  # Seoul, because it is the region that stays: a resource that says nothing
  # should land where the wiki is going, not where it is leaving. Every resource
  # and data source in Tokyo names local.tokyo_region, so nothing inherits this.
  # See #919.
  region = local.seoul_region
}

data "aws_caller_identity" "current" {}
