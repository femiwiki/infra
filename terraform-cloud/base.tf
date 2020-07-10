terraform {
  required_version = ">=0.12.9, <0.13"

  backend "remote" {
    organization = "femiwiki"

    workspaces {
      name = "terraform-cloud"
    }
  }
}

provider "tfe" {
  version = ">=0.19.0, <0.20"
}
