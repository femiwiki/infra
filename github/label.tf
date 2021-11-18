# It is not necessary to ensure that all repositories have the same labels.

locals {
  label_definition = {
    bug = {
      name        = "bug"
      description = ""
      color       = "ee0701"
    }

    disruption = {
      name        = "service disruption"
      description = ""
      color       = "ee0701"
    }

    enhancement = {
      name        = "enhancement"
      description = "New feature or request"
      color       = "a2eeef"
    }

    epic = {
      name        = "EPIC"
      description = ""
      color       = "fc7a6c"
    }

    femiwiki_discussion_needed = {
      name        = "femiwki discussion needed"
      description = ""
      color       = "d4c5f9"
    }

    invalid = {
      name        = "invalid"
      description = "This doesn't seem right"
      color       = "e4e669"
    }

    wontfix = {
      name        = "wontfix"
      description = "This will not be worked on"
      color       = "ffffff"
    }

    upstreamed = {
      name        = "upstreamed"
      description = ""
      color       = "ffffff"
    }

    note = {
      name        = "글쓰기"
      description = "공지사항이나 블로그 글로 문서화해야하는 이슈"
      color       = "0075ca"
    }

    operation = {
      name        = "operation"
      description = "점검, 인프라 작업"
      color       = "85d659"
    }

    patch_welcome = {
      name        = "patch welcome"
      description = ""
      color       = "7057ff"
    }

    ec2_instance_type = {
      name        = "ec2 instance types"
      description = ""
      color       = "f9d0c4"
    }

    savings_plan = {
      name        = "savings plan"
      description = ""
      color       = "f19643"
    }

    ci = {
      name        = "ci"
      description = "Continuous Integration"
      color       = "c5def5"
    }

    cd = {
      name        = "cd"
      description = "Continuous Deployment"
      color       = "c5def5"
    }

    mw1_34 = {
      name        = "mw1.34"
      description = "MediaWiki 1.34"
      color       = "5319e7"
    }

    mw1_35 = {
      name        = "mw1.35"
      description = "MediaWiki 1.35"
      color       = "5319e7"
    }

    mw1_36 = {
      name        = "mw1.36"
      description = "MediaWiki 1.36"
      color       = "c5def5"
    }

    mw1_37 = {
      name        = "mw1.37"
      description = "MediaWiki 1.37"
      color       = "c5def5"
    }

    docker = {
      name        = "docker"
      description = ""
      color       = "0db7ed"
    }

    consul = {
      name        = "consul"
      description = "HashiCorp Consul"
      color       = "ca2171"
    }

    yum = {
      name        = "yum"
      description = ""
      color       = "bfd4f2"
    }

    windows = {
      name        = "windows"
      description = "Microsoft Windows"
      color       = "00a4ef"
    }

    dependabot = {
      name        = "dependabot"
      description = "Dependabot"
      color       = "3b67d6"
    }

    monetary = {
      name        = "monetary"
      description = ""
      color       = "85bb65"
    }

    security = {
      name        = "security"
      description = ""
      color       = "005da9"
    }

    search = {
      name        = "search"
      description = ""
      color       = "bada55"
    }

    deprecation = {
      name        = "deprecation"
      description = ""
      color       = "ee0701"
    }

    ve = {
      name        = "visual editor"
      description = "Visual Editor"
      color       = "5bace1"
    }

    restbase = {
      name        = "restbase"
      description = ""
      color       = "f1c40e"
    }

    performance = {
      name        = "performance"
      description = ""
      color       = "ffa500"
    }

    monitoring = {
      name        = "monitoring"
      description = ""
      color       = "ffa500"
    }

    wikibase = {
      name        = "wikibase"
      description = ""
      color       = "366998"
    }
  }

  label_suite = {
    base     = ["bug", "enhancement", "invalid", "wontfix", "patch_welcome", "upstreamed"]
    base_ext = ["bug", "enhancement", "invalid", "wontfix", "patch_welcome", "upstreamed", "deprecation"]
  }

  repository_label_map = {
    femiwiki = concat(
      local.label_suite.base,
      [
        # general
        "epic",
        "disruption",
        "operation",
        "monetary",
        "ci",
        "cd",
        "note",
        "security",
        "search",
        "deprecation",
        "performance",
        "monitoring",

        # AWS
        "ec2_instance_type",
        "savings_plan",

        # Softwares-specific
        "docker",
        "consul",
        "yum",
        "windows",
        "dependabot",
        "mw1_35",
        "mw1_36",
        "mw1_37",
        "ve",
        "restbase",
        "wikibase",

        # etc
        "femiwiki_discussion_needed",
      ]
    )

    docker-mediawiki = concat(
      local.label_suite.base,
      [
        "note",
        "security",
        "search",
        "monetary",
        "performance",
        "deprecation",
        "ci",

        "ve",
        "restbase",
        "wikibase",
        "mw1_36",

        "femiwiki_discussion_needed",
      ]
    )

    nomad = concat(local.label_suite.base, ["cd", "disruption", "consul", "restbase"])

    infra       = concat(local.label_suite.base, ["operation", "monitoring", "disruption", "ec2_instance_type"])
    ".github"   = concat(local.label_suite.base, ["ci"])
    sns-discord = local.label_suite.base

    docker-parsoid  = local.label_suite.base
    docker-restbase = concat(local.label_suite.base, ["restbase"])
    docker-mathoid  = local.label_suite.base

    caddy-mwcache     = local.label_suite.base
    legunto           = local.label_suite.base
    maintenance       = local.label_suite.base
    OOUIFemiwikiTheme = local.label_suite.base
    remote-gadgets    = concat(local.label_suite.base, ["search", "windows"])

    backupbot  = local.label_suite.base
    tweetbot   = local.label_suite.base
    rankingbot = local.label_suite.base

    FemiwikiSkin                = concat(local.label_suite.base_ext, ["femiwiki_discussion_needed", "ve", "search", "mw1_35", "mw1_36", "mw1_37"])
    AchievementBadges           = concat(local.label_suite.base_ext, ["mw1_35", "mw1_36", "mw1_37"])
    DiscordRCFeed               = concat(local.label_suite.base_ext, ["mw1_37"])
    FacetedCategory             = concat(local.label_suite.base_ext, ["wikibase", "mw1_35", "mw1_36", "mw1_37"])
    Sanctions                   = concat(local.label_suite.base_ext, ["ve", "mw1_34", "mw1_35", "mw1_36", "mw1_37"])
    UnifiedExtensionForFemiwiki = concat(local.label_suite.base_ext, ["wikibase", "mw1_35", "mw1_36", "mw1_37"])
    PageViewInfoGA              = concat(local.label_suite.base_ext, ["mw1_37"])
  }

  // Flattening nested structures
  // See https://www.terraform.io/docs/language/functions/flatten.html#flattening-nested-structures-for-for_each
  repository_label_list = flatten([
    for repository in keys(local.repository_label_map) : [
      for tag in local.repository_label_map[repository] : {
        repository = repository
        tag        = tag
      }
    ]
  ])
}

resource "github_issue_label" "femiwiki" {
  // Flattening nested structures
  // See https://www.terraform.io/docs/language/functions/flatten.html#flattening-nested-structures-for-for_each
  for_each    = { for e in local.repository_label_list : "${e.repository}.${e.tag}" => e }
  repository  = each.value.repository
  name        = local.label_definition[each.value.tag].name
  description = local.label_definition[each.value.tag].description
  color       = local.label_definition[each.value.tag].color

  lifecycle {
    prevent_destroy = true
  }
}
