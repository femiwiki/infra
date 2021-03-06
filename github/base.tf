terraform {
  required_version = "~> 0.14.0"

  backend "remote" {
    organization = "femiwiki"

    workspaces {
      name = "github"
    }
  }

  required_providers {
    github = {
      source  = "hashicorp/github"
      version = "~> 4.0"
    }
  }
}

provider "github" {
  organization = "femiwiki"
}
