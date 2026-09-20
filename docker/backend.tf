terraform {

  backend "s3" {
    bucket       = "tfstate-302617221463-ap-northeast-1-an"
    key          = "docker/terraform.tfstate"
    region       = "ap-northeast-1"
    use_lockfile = true
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
  region = "ap-northeast-1"
}

provider "docker" {
  host = var.docker_host
}

data "aws_instance" "database" {
  filter {
    name   = "tag:Name"
    values = ["database"]
  }
  filter {
    name   = "instance-state-name"
    values = ["running"]
  }
}
