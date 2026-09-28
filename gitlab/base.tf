terraform {
  required_version = "~> 1.10"

  backend "s3" {
    bucket       = "tfstate-302617221463-ap-northeast-1-an"
    key          = "gitlab/terraform.tfstate"
    region       = "ap-northeast-1"
    use_lockfile = true
  }

  required_providers {
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "~> 19.4"
    }
  }
}

provider "gitlab" {
  token = var.gitlab_token
}

data "gitlab_group" "femiwiki" {
  full_path = "femiwiki"
}
