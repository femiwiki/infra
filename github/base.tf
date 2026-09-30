terraform {
  required_version = "~> 1.10"

  backend "s3" {
    bucket       = "tfstate-302617221463-ap-northeast-1-an"
    key          = "github/terraform.tfstate"
    region       = "ap-northeast-1"
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

    # Only until the next github apply rewrites the plaintext state.
    method "unencrypted" "migrate" {}

    state {
      method = method.aes_gcm.state

      fallback {
        method = method.unencrypted.migrate
      }
    }

    plan {
      method = method.aes_gcm.state
    }
  }

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

provider "github" {
  owner = "femiwiki"
  token = var.github_token
}
