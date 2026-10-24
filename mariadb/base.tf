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
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.7"
    }
    mysql = {
      source  = "petoju/mysql"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
}

# Plans log in as tofu-plan, which reads grants only, and their role cannot
# read the password of tofu, which applies.
ephemeral "aws_ssm_parameter" "login" {
  arn             = "arn:aws:ssm:ap-northeast-2:302617221463:parameter/mysql/users/${var.mysql_username}/password"
  with_decryption = true
}

ephemeral "aws_ssm_parameter" "repl" {
  arn             = "arn:aws:ssm:ap-northeast-2:302617221463:parameter/mariadb/users/repl/password"
  with_decryption = true
}

provider "mysql" {
  endpoint = var.mariadb_endpoint
  username = var.mysql_username
  password = ephemeral.aws_ssm_parameter.login.value
}
