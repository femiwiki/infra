terraform {
  required_version = "1.13.1"

  backend "s3" {
    bucket       = "tfstate-302617221463-ap-northeast-2-an"
    key          = "mariadb/terraform.tfstate"
    region       = "ap-northeast-2"
    use_lockfile = true
  }

  # "mariadb" is this state's and is never renamed. The aws key names are its own,
  # under which its state files the key metadata.
  encryption {
    key_provider "pbkdf2" "mariadb" {
      passphrase = var.state_passphrase
    }

    method "aes_gcm" "mariadb" {
      keys = key_provider.pbkdf2.mariadb
    }

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
      method   = method.aes_gcm.mariadb
      enforced = true
    }

    plan {
      method   = method.aes_gcm.mariadb
      enforced = true
    }
  }

  required_providers {
    mysql = {
      source  = "petoju/mysql"
      version = "~> 3.0"
    }
  }
}

data "terraform_remote_state" "aws" {
  backend = "s3"

  config = {
    bucket = "tfstate-302617221463-ap-northeast-1-an"
    key    = "aws/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

provider "mysql" {
  endpoint = var.mariadb_endpoint
  username = "tofu"
  password = data.terraform_remote_state.aws.outputs.mysql_tofu_password
}
