terraform {
  required_version = "~> 1.0"

  backend "remote" {
    organization = "femiwiki"

    workspaces {
      name = "aws"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.7"
    }
  }
}

provider "aws" {
  # Seoul, because it is the region that stays: a resource that says nothing
  # should land where the wiki is going, not where it is leaving. Every resource
  # and data source in Tokyo names local.tokyo_region, so nothing inherits this.
  # See #919.
  region = local.seoul_region
}

data "aws_caller_identity" "current" {}
