resource "tfe_workspace" "aws" {
  name              = "aws"
  organization      = tfe_organization.femiwiki.id
  auto_apply        = false
  queue_all_runs    = false
  terraform_version = "0.12.28"
  working_directory = "aws"
}

resource "tfe_workspace" "github" {
  name              = "github"
  organization      = tfe_organization.femiwiki.id
  auto_apply        = true
  queue_all_runs    = false
  terraform_version = "0.12.28"
  working_directory = "github"
}

resource "tfe_workspace" "terraform_cloud" {
  name              = "terraform-cloud"
  organization      = tfe_organization.femiwiki.id
  auto_apply        = true
  queue_all_runs    = false
  terraform_version = "0.12.28"
  working_directory = "terraform-cloud"
}
