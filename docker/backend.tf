terraform {

  backend "s3" {}

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

locals {
  docker_host = "ssh://ec2-user@${data.terraform_remote_state.aws.outputs.blue_ip}:22"
  docker_ssh_opts = [
    "-i", local_file.identity_file.filename,
    "-o", "StrictHostKeyChecking=no",
    "-o", "UserKnownHostsFile=/dev/null"
  ]
}

provider "docker" {
  host     = local.docker_host
  ssh_opts = [
    "-i", local_file.identity_file.filename,
    "-o", "StrictHostKeyChecking=no",
    "-o", "UserKnownHostsFile=/dev/null"
  ]
  disable_docker_daemon_check = false
}

resource "local_file" "identity_file" {
  file_permission = "0600"
  content         = sensitive(data.terraform_remote_state.aws.outputs.blue_private_key_pem)
  filename        = "${path.cwd}/identity_file.pem"
}

resource "null_resource" "wait_for_docker" {
  provisioner "local-exec" {
    command = <<-EOT
      until ssh ${join(" ", local.docker_ssh_opts)} ${local.docker_host} docker info; do
        echo "Waiting for Docker daemon to be available..."
        sleep 5
      done
      echo "Docker daemon is ready!"
    EOT
  }
}
