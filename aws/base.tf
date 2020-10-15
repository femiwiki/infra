terraform {
  required_version = ">= 0.13.4, < 0.14"

  backend "remote" {
    organization = "femiwiki"

    workspaces {
      name = "aws"
    }
  }

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region  = "ap-northeast-1"
  version = ">= 2.30.0, < 3"
}

provider "aws" {
  alias   = "us"
  region  = "us-east-1"
  version = ">= 2.30.0, < 3"
}
