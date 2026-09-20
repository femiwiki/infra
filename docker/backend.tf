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
  host          = "tcp://${data.terraform_remote_state.aws.outputs.docker_host_eip}:2376"
  ca_material   = data.terraform_remote_state.aws.outputs.client_ca_cert_pem
  cert_material = data.terraform_remote_state.aws.outputs.client_cert_pem
  key_material  = data.terraform_remote_state.aws.outputs.client_key_pem
}
