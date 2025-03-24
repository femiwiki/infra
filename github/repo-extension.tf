locals {
  extension_patterns = [
    # Cannot protect translatable branches now.
    # See https://phabricator.wikimedia.org/T235938#5592510 for detail.
    # "main",
    "REL[0-9]_[0-9][0-9]"
  ]
  extension_collaborator = true

  skin = merge(local.default_repo, {
    # temporarily disable requiring reviews due to too few development members.
    required_pull_request_reviews = [],
    required_status_checks_contexts = [[
      "test (composer-test)",
      "test (npm-test)",
      "test (phan)",
      "test (selenium)",
    ]]
    topics = [
      "mediawiki-skin",
    ],
    patterns     = local.extension_patterns,
    collaborator = local.extension_collaborator,
  })

  # local.default_repo is defined in repo.tf
  extension = merge(local.default_repo, {
    # temporarily disable requiring reviews due to too few development members.
    required_pull_request_reviews = [],
    required_status_checks_contexts = [[
      "test (REL1_42, composer-test)",
      "test (REL1_42, npm-test)",
      "test (REL1_42, phan)",
      "test (REL1_42, selenium)",
    ]]

    topics = [
      "mediawiki-extension",
    ],
    patterns     = local.extension_patterns,
    collaborator = local.extension_collaborator,
  })
}

# skin
module "femiwiki_skin" {
  source                          = "./modules/github-repository"
  name                            = "FemiwikiSkin"
  description                     = ":jack_o_lantern: FemiwikiSkin"
  homepage_url                    = "https://www.mediawiki.org/wiki/Special:MyLanguage/Skin:Femiwiki"
  topics                          = local.skin.topics
  enforce_admins                  = local.skin.enforce_admins
  required_pull_request_reviews   = local.skin.required_pull_request_reviews
  required_status_checks_contexts = [concat(local.skin.required_status_checks_contexts[0], ["semantic-pull-request"])]
  patterns                        = ["main"]
  collaborator                    = local.skin.collaborator
}

# extensions

module "unified_extension_for_femiwiki" {
  source                          = "./modules/github-repository"
  name                            = "UnifiedExtensionForFemiwiki"
  description                     = "Unified Extension For Femiwiki"
  homepage_url                    = "https://www.mediawiki.org/wiki/Special:MyLanguage/Extension:UnifiedExtensionForFemiwiki"
  topics                          = local.extension.topics
  enforce_admins                  = local.extension.enforce_admins
  required_pull_request_reviews   = local.extension.required_pull_request_reviews
  required_status_checks_contexts = local.extension.required_status_checks_contexts
  patterns                        = ["main"]
  collaborator                    = local.extension.collaborator
}
