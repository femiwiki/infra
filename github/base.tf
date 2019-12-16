terraform {
  required_version = ">=0.12.9, <0.13"

  backend "remote" {
    organization = "femiwiki"

    workspaces {
      name = "github"
    }
  }
}

provider "github" {
  organization = "femiwiki"
  version      = ">= 2.2.0, < 3"
}
