terraform {
  required_version = "~> 0.14.0"

  backend "remote" {
    organization = "femiwiki"

    workspaces {
      name = "aws"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.10"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

provider "aws" {
  alias  = "us"
  region = "us-east-1"
}
