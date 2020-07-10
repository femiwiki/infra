resource "tfe_workspace" "aws" {
  name              = "aws"
  organization      = tfe_organization.femiwiki.id
  auto_apply        = false
  queue_all_runs    = false
  terraform_version = "0.12.21"
  working_directory = "aws"
  vcs_repo {
    identifier         = "femiwiki/infra"
    ingress_submodules = false

    # See https://github.com/terraform-providers/terraform-provider-tfe/issues/147
    oauth_token_id = ""
  }
}

resource "tfe_workspace" "github" {
  name              = "github"
  organization      = tfe_organization.femiwiki.id
  auto_apply        = true
  queue_all_runs    = false
  terraform_version = "0.12.21"
  working_directory = "github"
  vcs_repo {
    identifier         = "femiwiki/infra"
    ingress_submodules = false

    # See https://github.com/terraform-providers/terraform-provider-tfe/issues/147
    oauth_token_id = ""
  }
}

resource "tfe_workspace" "terraform_cloud" {
  name              = "terraform-cloud"
  organization      = tfe_organization.femiwiki.id
  auto_apply        = true
  queue_all_runs    = false
  terraform_version = "0.12.21"
  working_directory = "terraform-cloud"
  vcs_repo {
    identifier         = "femiwiki/infra"
    ingress_submodules = false

    # See https://github.com/terraform-providers/terraform-provider-tfe/issues/147
    oauth_token_id = ""
  }
}
