terraform {
  required_version = "1.13.1"

  backend "s3" {
    bucket       = "tfstate-302617221463-ap-northeast-2-an"
    key          = "mariadb/terraform.tfstate"
    region       = "ap-northeast-2"
    use_lockfile = true
  }

  # "mariadb" is this state's and is never renamed.
  encryption {
    key_provider "pbkdf2" "mariadb" {
      passphrase = var.state_passphrase
    }

    method "aes_gcm" "mariadb" {
      keys = key_provider.pbkdf2.mariadb
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

provider "mysql" {
  endpoint = var.mariadb_endpoint
  username = var.mysql_username
  password = var.mysql_password
}
