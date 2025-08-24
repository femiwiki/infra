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
  host = "ssh://ec2-user@${data.terraform_remote_state.aws.outputs.blue_ip}:22"
  ssh_opts = [
    "-i", "identity_file.pem",
    "-o", "StrictHostKeyChecking=no",
    "-o", "UserKnownHostsFile=/dev/null"
  ]
}

resource "local_file" "identity_file" {
  file_permission = "0600"
  content         = data.terraform_remote_state.aws.outputs.blue_identity_private_key
  filename        = "identity_file.pem"
}

