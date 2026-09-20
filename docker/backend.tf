terraform {

  backend "s3" {
    bucket       = "tfstate-302617221463-ap-northeast-1-an"
    key          = "docker/terraform.tfstate"
    region       = "ap-northeast-1"
    use_lockfile = true
  }

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

data "terraform_remote_state" "aws" {
  backend = "remote"
  config = {
    organization = "femiwiki"
    workspaces = {
      name = "aws"
    }
  }
}

provider "docker" {
  host = "tcp://127.0.0.1:2376"
}
