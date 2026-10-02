terraform {
  required_version = "~> 1.10"

  backend "s3" {
    bucket       = "tfstate-302617221463-ap-northeast-1-an"
    key          = "docker/terraform.tfstate"
    region       = "ap-northeast-1"
    use_lockfile = true
  }

  # Only to read the aws outputs, under aws/base.tf's names
  encryption {
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
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.7"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
}

provider "docker" {
  host = var.docker_host
}

data "aws_instances" "database" {
  instance_tags        = { Name = "database-5" }
  instance_state_names = ["running"]
}

data "terraform_remote_state" "aws" {
  backend = "s3"

  config = {
    bucket = "tfstate-302617221463-ap-northeast-1-an"
    key    = "aws/terraform.tfstate"
    region = "ap-northeast-1"
  }
}
