# It is not necessary to ensure that all repositories have the same labels.

locals {
  label_definition = {
    alert = {
      name        = "alert"
      description = "Opened by an automated alert"
      color       = "ffa500"
    }

    cd = {
      name        = "cd"
      description = "Continuous Deployment"
      color       = "c5def5"
    }

    ci = {
      name        = "ci"
      description = "Continuous Integration"
      color       = "c5def5"
    }

    cloud_watch = {
      name        = "cloud watch"
      description = ""
      color       = "230746"
    }

    consul = {
      name        = "consul"
      description = "HashiCorp Consul"
      color       = "ca2171"
    }

    dependabot = {
      name        = "dependabot"
      description = "Dependabot"
      color       = "3b67d6"
    }

    deprecation = {
      name        = "deprecation"
      description = ""
      color       = "ee0701"
    }

    disruption = {
      name        = "service disruption"
      description = ""
      color       = "ee0701"
    }

    docker = {
      name        = "docker"
      description = ""
      color       = "0db7ed"
    }

    ec2_instance_type = {
      name        = "ec2 instance types"
      description = ""
      color       = "f9d0c4"
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

    good_first_issue = {
      name        = "good first issue"
      description = "Left for first-time contributors; Claude does not take it"
      color       = "7057ff"
    }

    help_wanted = {
      name        = "help wanted"
      description = "Extra attention is needed"
      color       = "008672"
    }

    invalid = {
      name        = "invalid"
      description = "This doesn't seem right"
      color       = "e4e669"
    }

    monetary = {
      name        = "monetary"
      description = ""
      color       = "85bb65"
    }

    monitoring = {
      name        = "monitoring"
      description = ""
      color       = "ffa500"
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

    mw1_38 = {
      name        = "mw1.38"
      description = "MediaWiki 1.38"
      color       = "c5def5"
    }

    mw1_39 = {
      name        = "mw1.39"
      description = "MediaWiki 1.39"
      color       = "c5def5"
    }

    mw1_40 = {
      name        = "mw1.40"
      description = "MediaWiki 1.40"
      color       = "c5def5"
    }

    mw1_41 = {
      name        = "mw1.41"
      description = "MediaWiki 1.41"
      color       = "c5def5"
    }

    mw1_42 = {
      name        = "mw1.42"
      description = "MediaWiki 1.42"
      color       = "c5def5"
    }

    mw1_43 = {
      name        = "mw1.43"
      description = "MediaWiki 1.43"
      color       = "c5def5"
    }

    mw1_44 = {
      name        = "mw1.44"
      description = "MediaWiki 1.44"
      color       = "c5def5"
    }

    mw1_45 = {
      name        = "mw1.45"
      description = "MediaWiki 1.45"
      color       = "c5def5"
    }

    mw1_47 = {
      name        = "mw1.47"
      description = "MediaWiki 1.47"
      color       = "c5def5"
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

    performance = {
      name        = "performance"
      description = ""
      color       = "ffa500"
    }

    restbase = {
      name        = "restbase"
      description = ""
      color       = "f1c40e"
    }

    savings_plan = {
      name        = "savings plan"
      description = ""
      color       = "f19643"
    }

    search = {
      name        = "search"
      description = ""
      color       = "bada55"
    }

    security = {
      name        = "security"
      description = ""
      color       = "005da9"
    }

    upstreamed = {
      name        = "upstreamed"
      description = ""
      color       = "ffffff"
    }

    ve = {
      name        = "visual editor"
      description = "Visual Editor"
      color       = "5bace1"
    }

    wikibase = {
      name        = "wikibase"
      description = ""
      color       = "366998"
    }

    windows = {
      name        = "windows"
      description = "Microsoft Windows"
      color       = "00a4ef"
    }

    wontfix = {
      name        = "wontfix"
      description = "This will not be worked on"
      color       = "ffffff"
    }

    yum = {
      name        = "yum"
      description = ""
      color       = "bfd4f2"
    }
  }

  base_label_suite = ["enhancement", "invalid", "wontfix", "help_wanted", "good_first_issue", "upstreamed", "ci"]
  ext_label_suite  = concat(local.base_label_suite, ["deprecation"])


  repository_label_map = {
    (module.femiwiki.name) = concat(
      local.base_label_suite,
      [
        # general
        "epic",
        "disruption",
        "operation",
        "monetary",
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
        "cloud_watch",

        # Softwares-specific
        "docker",
        "consul",
        "yum",
        "windows",
        "dependabot",
        "mw1_35",
        "mw1_36",
        "mw1_37",
        "mw1_38",
        "mw1_39",
        "mw1_40",
        "mw1_42",
        "mw1_43",
        "mw1_44",
        "mw1_45",
        "mw1_47",
        "ve",
        "restbase",
        "wikibase",

        # etc
        "femiwiki_discussion_needed",
      ]
    )

    (module.docker_mediawiki.name) = concat(
      local.base_label_suite,
      [
        "note",
        "security",
        "search",
        "monetary",
        "performance",
        "deprecation",

        "ve",
        "restbase",
        "wikibase",
        "mw1_36",
        "mw1_38",
        "mw1_39",
        "mw1_42",
        "mw1_43",
        "mw1_44",
        "mw1_45",
        "mw1_47",

        "femiwiki_discussion_needed",
      ]
    )

    (module.infra.name) = concat(
      local.base_label_suite, [
        "operation",
        "monitoring",
        "alert",
        "disruption",

        # Products
        "ec2_instance_type",
        "cloud_watch",
        "consul",
      ]
    )

    (module.dot_github.name)         = local.base_label_suite
    (module.quibble_action.name)     = ["ci", "good_first_issue"]
    (module.femiwiki_github_io.name) = ["ci", "good_first_issue"]
    # Renamed to lambda; the API answers the old name with a redirect, which the
    # provider may not follow for writes, so this list is frozen.
    sns-discord = ["enhancement", "invalid", "wontfix", "help_wanted", "upstreamed", "ci"]

    (module.caddy_mwcache.name)       = local.base_label_suite
    (module.caddy_cloudfront_ip.name) = local.base_label_suite
    (module.delayed_job_queue.name)   = local.ext_label_suite
    (module.fedifeeds.name)           = local.ext_label_suite
    (module.http_signatures.name)     = local.base_label_suite
    (module.legunto.name)             = local.base_label_suite
    (module.ooui_femiwiki_theme.name) = local.ext_label_suite
    (module.webfinger.name)           = local.base_label_suite
    (module.remote_gadgets.name)      = concat(local.base_label_suite, ["search", "windows", "mw1_38", "mw1_39", "mw1_40", "mw1_41", "mw1_42"])

    (module.tweetbot.name)   = local.base_label_suite
    (module.rankingbot.name) = local.base_label_suite

    (module.femiwiki_skin.name)                  = concat(local.ext_label_suite, ["femiwiki_discussion_needed", "ve", "search", "mw1_35", "mw1_36", "mw1_37", "mw1_39", "mw1_42", "mw1_43", "mw1_44", "mw1_45", "mw1_47"])
    (module.unified_extension_for_femiwiki.name) = concat(local.ext_label_suite, ["wikibase", "mw1_35", "mw1_36", "mw1_37", "mw1_39", "mw1_42", "mw1_43", "mw1_44", "mw1_45", "mw1_47"])
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

# legunto already had GitHub's default "good first issue" label.
import {
  to = github_issue_label.femiwiki["legunto.good_first_issue"]
  id = "legunto:good first issue"
}

resource "github_issue_label" "femiwiki" {
  // Flattening nested structures
  // See https://www.terraform.io/docs/language/functions/flatten.html#flattening-nested-structures-for-for_each
  for_each    = { for e in local.repository_label_list : "${e.repository}.${e.tag}" => e }
  repository  = each.value.repository
  name        = local.label_definition[each.value.tag].name
  description = local.label_definition[each.value.tag].description
  color       = local.label_definition[each.value.tag].color
}
