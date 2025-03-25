locals {
  # local.default_repo is defined in repo.tf
  extension = merge(local.default_repo, {
    collaborator = true,
    # temporarily disable requiring reviews due to too few development members.
    required_pull_request_reviews = [],

    patterns = [
      "REL[0-9]_[0-9][0-9]"
      # Cannot protect translatable branches now.
      # See https://phabricator.wikimedia.org/T235938#5592510 for detail.
      # "main",
    ],
  })
}

module "femiwiki_skin" {
  source       = "./modules/github-repository"
  name         = "FemiwikiSkin"
  description  = ":jack_o_lantern: FemiwikiSkin"
  homepage_url = "https://www.mediawiki.org/wiki/Special:MyLanguage/Skin:Femiwiki"
  topics = [
    "mediawiki-skin",
  ]
  enforce_admins                = local.extension.enforce_admins
  required_pull_request_reviews = local.extension.required_pull_request_reviews
  required_status_checks_contexts = [[
    "test (REL1_42, composer-test)",
    "test (REL1_42, npm-test)",
    "test (REL1_42, phan)",
    "test (REL1_42, selenium)",
    "semantic-pull-request",
  ]]
  patterns     = ["main"]
  collaborator = local.extension.collaborator
}

module "unified_extension_for_femiwiki" {
  source                        = "./modules/github-repository"
  name                          = "UnifiedExtensionForFemiwiki"
  description                   = "Unified Extension For Femiwiki"
  homepage_url                  = "https://www.mediawiki.org/wiki/Special:MyLanguage/Extension:UnifiedExtensionForFemiwiki"
  topics                        = ["mediawiki-extension"]
  enforce_admins                = local.extension.enforce_admins
  required_pull_request_reviews = local.extension.required_pull_request_reviews
  required_status_checks_contexts = [[
    "test (REL1_42, composer-test)",
    "test (REL1_42, npm-test)",
    "test (REL1_42, phan)",
    "test (REL1_42, selenium)",
  ]]
  patterns     = ["main"]
  collaborator = local.extension.collaborator
}
