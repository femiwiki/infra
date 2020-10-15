terraform {
  required_version = "~> 0.13.4"

  backend "remote" {
    organization = "femiwiki"

    workspaces {
      name = "github"
    }
  }

  required_providers {
    github = {
      source = "hashicorp/github"
    }
  }
}

provider "github" {
  organization = "femiwiki"
  version      = "~> 3.1"
}
