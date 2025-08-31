terraform {

  backend "remote" {
    organization = "femiwiki"

    workspaces {
      name = "docker"
    }
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
  host          = "tcp://${data.terraform_remote_state.aws.outputs.docker_host_eip}:2376"
  ca_material   = data.terraform_remote_state.aws.outputs.client_ca_cert_pem
  cert_material = data.terraform_remote_state.aws.outputs.client_cert_pem
  key_material  = data.terraform_remote_state.aws.outputs.client_key_pem
}
