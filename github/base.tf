terraform {
  required_version = "~> 0.15.0"

  backend "remote" {
    organization = "femiwiki"

    workspaces {
      name = "github"
    }
  }

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 4.0"
    }
  }
}

provider "github" {
  organization = "femiwiki"
}
