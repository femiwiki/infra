# The docker workspace becomes app (femiwiki/femiwiki#577). Both names have
# roles until the workflows use the new one, and the old ones go after.
locals {
  app_workspace_names = toset(["docker", "app"])
}

module "infra_app" {
  for_each = local.app_workspace_names

  source             = "terraform-aws-modules/iam/aws//modules/iam-role"
  version            = "6.8.2"
  name               = "infra-${each.key}"
  use_name_prefix    = false
  description        = "Allows GitHub Actions workflows of femiwiki/infra to apply the app workspace."
  enable_github_oidc = true
  oidc_subjects = [
    "femiwiki@21275875/infra@188597503:environment:${each.key}",
  ]
}

resource "aws_iam_role_policy" "infra_app" {
  for_each = local.app_workspace_names

  name   = "InfraDocker"
  role   = module.infra_app[each.key].name
  policy = data.aws_iam_policy_document.infra_docker.json
}

data "aws_iam_policy_document" "infra_docker" {
  statement {
    sid       = "State"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = [for b in local.tfstate_buckets : "${b}/docker/terraform.tfstate*"]
  }

  statement {
    sid       = "ReadAwsOutputs"
    actions   = ["s3:GetObject"]
    resources = [for b in local.tfstate_buckets : "${b}/aws/terraform.tfstate"]
  }

  statement {
    sid       = "ReadGcpOutputs"
    actions   = ["s3:GetObject"]
    resources = [for b in local.tfstate_buckets : "${b}/gcp/terraform.tfstate"]
  }

  statement {
    sid       = "StateBucket"
    actions   = ["s3:ListBucket"]
    resources = local.tfstate_buckets
  }

  statement {
    sid       = "ReadEc2"
    actions   = ["ec2:Describe*"]
    resources = ["*"]
  }

  statement {
    sid       = "ReadMediawikiDbPassword"
    actions   = ["ssm:GetParameter"]
    resources = [data.aws_ssm_parameter.secret["/mysql/users/mediawiki/password"].arn]
  }

  # The app hosts, which docker/ launches and retires (femiwiki/femiwiki#577).
  # Only instances tagged Role=app, from this subnet and these security groups.
  statement {
    sid       = "LaunchAppHost"
    actions   = ["ec2:RunInstances"]
    resources = ["arn:aws:ec2:${local.region}:${data.aws_caller_identity.current.account_id}:instance/*"]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/Role"
      values   = ["app"]
    }
  }

  statement {
    sid     = "LaunchAppHostWith"
    actions = ["ec2:RunInstances"]
    resources = concat(
      [
        "arn:aws:ec2:${local.region}::image/*",
        "arn:aws:ec2:${local.region}:${data.aws_caller_identity.current.account_id}:volume/*",
        "arn:aws:ec2:${local.region}:${data.aws_caller_identity.current.account_id}:network-interface/*",
        aws_subnet.main.arn,
      ],
      [for sg in [aws_security_group.web, aws_security_group.database_client, aws_security_group.instance_connect] : sg.arn],
    )
  }

  statement {
    sid       = "TagAtLaunch"
    actions   = ["ec2:CreateTags"]
    resources = ["arn:aws:ec2:${local.region}:${data.aws_caller_identity.current.account_id}:*/*"]

    condition {
      test     = "StringEquals"
      variable = "ec2:CreateAction"
      values   = ["RunInstances", "AllocateAddress"]
    }
  }

  statement {
    sid = "ManageAppHost"
    actions = [
      "ec2:CreateTags",
      "ec2:DeleteTags",
      "ec2:ModifyInstanceAttribute",
      "ec2:ModifyInstanceCreditSpecification",
      "ec2:TerminateInstances",
      "ec2:AssociateAddress",
      "ec2:DisassociateAddress",
    ]
    resources = ["arn:aws:ec2:${local.region}:${data.aws_caller_identity.current.account_id}:instance/*"]

    condition {
      test     = "StringEquals"
      variable = "ec2:ResourceTag/Role"
      values   = ["app"]
    }
  }

  statement {
    sid       = "AppHostAddress"
    actions   = ["ec2:AllocateAddress", "ec2:ReleaseAddress", "ec2:AssociateAddress", "ec2:DisassociateAddress", "ec2:CreateTags"]
    resources = ["arn:aws:ec2:${local.region}:${data.aws_caller_identity.current.account_id}:elastic-ip/*"]
  }

  statement {
    sid       = "PassAppHostRole"
    actions   = ["iam:PassRole"]
    resources = [module.femiwiki.arn]
  }

  statement {
    sid       = "ReadZone"
    actions   = ["route53:GetHostedZone", "route53:ListResourceRecordSets", "route53:ListTagsForResource", "route53:GetChange"]
    resources = [aws_route53_zone.femiwiki_com.arn, "arn:aws:route53:::change/*"]
  }

  statement {
    sid       = "OriginRecord"
    actions   = ["route53:ChangeResourceRecordSets"]
    resources = [aws_route53_zone.femiwiki_com.arn]

    condition {
      test     = "ForAllValues:StringEquals"
      variable = "route53:ChangeResourceRecordSetsNormalizedRecordNames"
      values   = ["cloudfront-origin.femiwiki.com"]
    }
  }

  # A key for each generation, replaced as the generation moves (femiwiki/femiwiki#528)
  statement {
    sid       = "SmtpKeys"
    actions   = ["iam:CreateAccessKey", "iam:DeleteAccessKey", "iam:ListAccessKeys"]
    resources = [for u in aws_iam_user.smtp : u.arn]
  }

  # Whichever app host the docker workspace applies to
  statement {
    sid       = "DockerPortForward"
    actions   = ["ssm:StartSession"]
    resources = ["arn:aws:ec2:${local.region}:${data.aws_caller_identity.current.account_id}:instance/*"]

    condition {
      test     = "StringEquals"
      variable = "ssm:resourceTag/DockerTarget"
      values   = ["true"]
    }
  }

  statement {
    sid       = "PortForwardDocument"
    actions   = ["ssm:StartSession"]
    resources = ["arn:aws:ssm:${local.region}::document/AWS-StartPortForwardingSession"]
  }

  statement {
    sid     = "OwnSessions"
    actions = ["ssm:TerminateSession", "ssm:ResumeSession", "ssmmessages:OpenDataChannel"]
    resources = [
      # SSM names a session after the role session name, GitHubActions-<random>,
      # while aws:userid for an assumed role expands to <role id>:GitHubActions,
      # so the pattern below never matches one of these.
      "arn:aws:ssm:*:*:session/GitHubActions-*",
      "arn:aws:ssm:*:*:session/$${aws:userid}-*",
    ]
  }
}

module "infra_app_plan" {
  for_each = local.app_workspace_names

  source             = "terraform-aws-modules/iam/aws//modules/iam-role"
  version            = "6.8.2"
  name               = "infra-${each.key}-plan"
  use_name_prefix    = false
  description        = "Allows GitHub Actions workflows of femiwiki/infra to plan the app workspace through the read-only Docker API."
  enable_github_oidc = true
  oidc_subjects      = ["femiwiki@21275875/infra@188597503:pull_request"]
}

resource "aws_iam_role_policy" "infra_app_plan" {
  for_each = local.app_workspace_names

  name   = "InfraDockerPlan"
  role   = module.infra_app_plan[each.key].name
  policy = data.aws_iam_policy_document.infra_docker_plan.json
}

data "aws_iam_policy_document" "infra_docker_plan" {
  statement {
    sid       = "ReadState"
    actions   = ["s3:GetObject"]
    resources = [for b in local.tfstate_buckets : "${b}/docker/terraform.tfstate"]
  }

  statement {
    sid       = "StateLock"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = [for b in local.tfstate_buckets : "${b}/docker/terraform.tfstate.tflock"]
  }

  statement {
    sid       = "ReadAwsOutputs"
    actions   = ["s3:GetObject"]
    resources = [for b in local.tfstate_buckets : "${b}/aws/terraform.tfstate"]
  }

  statement {
    sid       = "ReadGcpOutputs"
    actions   = ["s3:GetObject"]
    resources = [for b in local.tfstate_buckets : "${b}/gcp/terraform.tfstate"]
  }

  statement {
    sid       = "StateBucket"
    actions   = ["s3:ListBucket"]
    resources = local.tfstate_buckets
  }

  statement {
    sid       = "ReadEc2"
    actions   = ["ec2:Describe*"]
    resources = ["*"]
  }

  statement {
    sid       = "ReadZone"
    actions   = ["route53:GetHostedZone", "route53:ListResourceRecordSets", "route53:ListTagsForResource"]
    resources = [aws_route53_zone.femiwiki_com.arn]
  }

  statement {
    sid       = "ReadMediawikiDbPassword"
    actions   = ["ssm:GetParameter"]
    resources = [data.aws_ssm_parameter.secret["/mysql/users/mediawiki/password"].arn]
  }

  statement {
    sid       = "ReadSmtpKeys"
    actions   = ["iam:ListAccessKeys"]
    resources = [for u in aws_iam_user.smtp : u.arn]
  }

  # Whichever app host the docker workspace applies to
  statement {
    sid       = "ReadOnlyDockerApiForward"
    actions   = ["ssm:StartSession"]
    resources = ["arn:aws:ec2:${local.region}:${data.aws_caller_identity.current.account_id}:instance/*"]

    condition {
      test     = "StringEquals"
      variable = "ssm:resourceTag/DockerTarget"
      values   = ["true"]
    }
  }

  statement {
    sid       = "ReadOnlyForwardDocument"
    actions   = ["ssm:StartSession"]
    resources = [aws_ssm_document.docker_api_readonly_forward.arn]
  }

  statement {
    sid     = "OwnSessions"
    actions = ["ssm:TerminateSession", "ssm:ResumeSession", "ssmmessages:OpenDataChannel"]
    resources = [
      "arn:aws:ssm:*:*:session/GitHubActions-*",
      "arn:aws:ssm:*:*:session/$${aws:userid}-*",
    ]
  }
}

data "aws_iam_policy_document" "docker_ssh" {
  statement {
    actions   = ["ec2-instance-connect:SendSSHPublicKey"]
    resources = ["arn:aws:ec2:${local.region}:${data.aws_caller_identity.current.account_id}:instance/*"]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/DockerTarget"
      values   = ["true"]
    }
  }
}

resource "aws_iam_role_policy" "infra_app_ssh" {
  for_each = local.app_workspace_names

  name   = "DockerSsh"
  role   = module.infra_app[each.key].name
  policy = data.aws_iam_policy_document.docker_ssh.json
}

resource "aws_iam_role_policy" "database_swap_ssh" {
  name   = "DockerSsh"
  role   = module.database_swap.name
  policy = data.aws_iam_policy_document.docker_ssh.json
}
