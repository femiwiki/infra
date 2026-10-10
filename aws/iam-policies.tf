locals {
  parameter_store_regions = [local.tokyo_region, local.seoul_region]
}

#
# IAM Policies
#
resource "aws_iam_policy" "force_mfa" {
  name        = "Force_MFA"
  description = "This policy allows users to manage their own passwords and MFA devices but nothing else unless they authenticate with MFA."
  path        = "/"

  policy = data.aws_iam_policy_document.force_mfa.json
}

data "aws_iam_policy_document" "force_mfa" {
  // Reference:
  //   https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_examples_aws_my-sec-creds-self-manage.html

  statement {
    sid = "AllowViewAccountInfo"
    actions = [
      "iam:GetAccountPasswordPolicy",
      "iam:GetAccountSummary",
      "iam:ListVirtualMFADevices",
    ]
    resources = ["*"]
  }

  statement {
    sid = "AllowIndividualUserToSeeAndManageOnlyTheirOwnAccountInformation"
    actions = [
      // Allow managing own password
      "iam:ListUsers",
      "iam:GetUser",
      "iam:ChangePassword",
      // Allow managing own access keys
      "iam:CreateAccessKey",
      "iam:DeleteAccessKey",
      "iam:ListAccessKeys",
      "iam:UpdateAccessKey",
      // Allow managing own signing certificates
      "iam:ListSigningCertificates",
      "iam:DeleteSigningCertificate",
      "iam:UpdateSigningCertificate",
      "iam:UploadSigningCertificate",
      // Allow managing own SSH public keys
      "iam:ListSSHPublicKeys",
      "iam:GetSSHPublicKey",
      "iam:DeleteSSHPublicKey",
      "iam:UpdateSSHPublicKey",
      "iam:UploadSSHPublicKey",
      // Allow managing own service-specific credentials
      "iam:CreateServiceSpecificCredential",
      "iam:DeleteServiceSpecificCredential",
      "iam:ListServiceSpecificCredentials",
      "iam:ResetServiceSpecificCredential",
      "iam:UpdateServiceSpecificCredential",
      // Allow managing own MFA devices
      "iam:EnableMFADevice",
      "iam:ListMFADevices",
      "iam:ResyncMFADevice",
      "iam:DeactivateMFADevice",
    ]
    resources = ["arn:aws:iam::*:user/$${aws:username}"]
  }

  // Allow managing own virtual MFA device
  statement {
    sid = "AllowManageOwnVirtualMFADevice"
    actions = [
      "iam:CreateVirtualMFADevice",
      "iam:DeleteVirtualMFADevice",
    ]
    resources = ["arn:aws:iam::*:mfa/$${aws:username}"]
  }

  // Without MFA, only the actions below are allowed
  statement {
    sid    = "DenyAllExceptListedIfNoMFA"
    effect = "Deny"
    not_actions = [
      // Allow changing password
      "iam:ListUsers",
      "iam:GetUser",
      "iam:ChangePassword",
      "iam:GetAccountPasswordPolicy",
      "sts:GetSessionToken",
      // Allow managing virtual MFA devices
      "iam:ListVirtualMFADevices",
      "iam:CreateVirtualMFADevice",
      "iam:DeleteVirtualMFADevice",
      // Allow managing MFA devices
      "iam:ListMFADevices",
      "iam:EnableMFADevice",
      "iam:ResyncMFADevice",
    ]
    resources = ["*"]

    condition {
      test     = "BoolIfExists"
      variable = "aws:MultiFactorAuthPresent"
      values   = [false]
    }
  }
}

resource "aws_iam_policy" "amazon_s3_access" {
  name        = "AmazonS3Access"
  description = "Provide Access to Amazon S3 buckets."

  policy = data.aws_iam_policy_document.amazon_s3_access.json
}

# Workaround of unnecessary change proposal issue. See references for the
# further details.
#
# References:
#   https://github.com/hashicorp/terraform/issues/27171#issuecomment-740249394
#   https://github.com/hashicorp/terraform/issues/27282
locals {
  caddy_certs   = aws_s3_bucket.caddy_certs.arn
  backups       = aws_s3_bucket.backups.arn
  backups_seoul = aws_s3_bucket.backups_seoul.arn
  uploads_seoul = aws_s3_bucket.uploads_seoul.arn
  rate_limit    = aws_s3_bucket.rate_limit.arn
}

data "aws_iam_policy_document" "amazon_s3_access" {
  statement {
    actions = ["s3:*"]
    resources = [
      "${local.uploads_seoul}/*",
    ]
  }

  statement {
    actions = [
      "s3:Get*",
      "s3:List*"
    ]
    resources = [
      local.uploads_seoul,
    ]
  }
}

resource "aws_iam_policy" "route53" {
  name        = "Route53Access"
  description = "Provide Access to route53."

  policy = data.aws_iam_policy_document.route53.json
}

data "aws_iam_policy_document" "route53" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "route53:ListResourceRecordSets",
      "route53:ChangeResourceRecordSets",
    ]
    resources = ["arn:aws:route53:::hostedzone/${aws_route53_zone.femiwiki_com.zone_id}"]
  }

  statement {
    actions = [
      "route53:ListHostedZonesByName",
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "route53:GetChange",
    ]
    resources = ["arn:aws:route53:::change/*"]
  }
}

resource "aws_iam_policy" "access_caddycerts" {
  name        = "AccessCaddycerts"
  description = "Allows to read and write caddycerts"

  policy = data.aws_iam_policy_document.access_caddycerts.json
}

data "aws_iam_policy_document" "access_caddycerts" {
  statement {
    actions   = ["s3:ListBucket"]
    resources = [local.caddy_certs]
  }
  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = ["${local.caddy_certs}/caddycerts/*"]
  }
}

resource "aws_iam_policy" "share_rate_limit_state" {
  name        = "ShareRateLimitState"
  description = "Allows Caddy to share its rate limit counters between containers"

  policy = data.aws_iam_policy_document.share_rate_limit_state.json
}

data "aws_iam_policy_document" "share_rate_limit_state" {
  statement {
    actions   = ["s3:ListBucket"]
    resources = [local.rate_limit]
  }
  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = ["${local.rate_limit}/*"]
  }
}

resource "aws_iam_policy" "read_secret_parameters" {
  name        = "ReadSecretParameters"
  description = "Allows instances to read their own secrets from Parameter Store at boot"

  policy = data.aws_iam_policy_document.read_secret_parameters.json
}

data "aws_iam_policy_document" "read_secret_parameters" {
  statement {
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath",
    ]
    resources = flatten([
      for region in local.parameter_store_regions : [
        "arn:aws:ssm:${region}:${data.aws_caller_identity.current.account_id}:parameter/mediawiki/*",
        "arn:aws:ssm:${region}:${data.aws_caller_identity.current.account_id}:parameter/mysql/*",
      ]
    ])
  }

  statement {
    actions   = ["ssm:DescribeParameters"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "read_alloy_parameters" {
  name        = "ReadAlloyParameters"
  description = "Allows instances to read the Grafana Cloud credentials Alloy writes with"

  policy = data.aws_iam_policy_document.read_alloy_parameters.json
}

data "aws_iam_policy_document" "read_alloy_parameters" {
  statement {
    actions   = ["ssm:GetParameter"]
    resources = [for region in local.parameter_store_regions : "arn:aws:ssm:${region}:${data.aws_caller_identity.current.account_id}:parameter/alloy/*"]
  }
}

resource "aws_iam_policy" "upload_backup" {
  name        = "UploadBackup"
  description = "Allows to upload to the backup bucket"

  policy = data.aws_iam_policy_document.upload_backup.json
}

data "aws_iam_policy_document" "upload_backup" {
  statement {
    actions   = ["s3:PutObject"]
    resources = ["${local.backups_seoul}/*"]
  }
}

resource "aws_iam_policy" "read_backup" {
  name        = "ReadBackup"
  description = "Allows to read the MySQL backups back"

  policy = data.aws_iam_policy_document.read_backup.json
}

data "aws_iam_policy_document" "read_backup" {
  # Both buckets: the Seoul one is where a dump is written now, and the Tokyo
  # one still holds everything from before femiwiki/infra#892, which a restore
  # of anything older has to reach.
  statement {
    actions = ["s3:GetObject"]
    resources = [
      "${local.backups_seoul}/mysql/*",
      "${local.backups_seoul}/seed/*",
      "${local.backups}/mysql/*",
      "${local.backups}/seed/*",
    ]
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = [local.backups_seoul, local.backups]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = ["mysql/*", "seed/*"]
    }
  }
}

resource "aws_iam_policy" "read_mysql_user_parameters" {
  name        = "ReadMysqlUserParameters"
  description = "Allows the database instance to read the MySQL account parameters at boot"

  policy = data.aws_iam_policy_document.read_mysql_user_parameters.json
}

data "aws_iam_policy_document" "read_mysql_user_parameters" {
  statement {
    actions   = ["ssm:GetParameter"]
    resources = [for region in local.parameter_store_regions : "arn:aws:ssm:${region}:${data.aws_caller_identity.current.account_id}:parameter/mysql/users/*"]
  }
}

resource "aws_iam_policy" "read_backup_healthcheck_url" {
  name        = "ReadBackupHealthcheckUrl"
  description = "Allows the database instance to read the URL it pings after a dump"

  policy = data.aws_iam_policy_document.read_backup_healthcheck_url.json
}

data "aws_iam_policy_document" "read_backup_healthcheck_url" {
  statement {
    actions   = ["ssm:GetParameter"]
    resources = [for region in local.parameter_store_regions : "arn:aws:ssm:${region}:${data.aws_caller_identity.current.account_id}:parameter/mysql/backup/*"]
  }
}

resource "aws_iam_policy" "write_mysql_root_password" {
  name        = "WriteMysqlRootPassword"
  description = "Allows a database instance to publish the root password it generates at first boot, under its own server id"

  policy = data.aws_iam_policy_document.write_mysql_root_password.json
}

data "aws_iam_policy_document" "write_mysql_root_password" {
  statement {
    actions   = ["ssm:PutParameter"]
    resources = [for region in local.parameter_store_regions : "arn:aws:ssm:${region}:${data.aws_caller_identity.current.account_id}:parameter/mysql/servers/*/root/password"]
  }

  statement {
    actions   = ["kms:Encrypt", "kms:GenerateDataKey"]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["ssm.${local.tokyo_region}.amazonaws.com"]
    }
  }
}


resource "aws_iam_policy" "get_google_subject_token" {
  name        = "GetGoogleSubjectToken"
  description = "Allows instances to get the JWT that Google exchanges for PageViewInfoGA's access"

  policy = data.aws_iam_policy_document.get_google_subject_token.json
}

data "aws_iam_policy_document" "get_google_subject_token" {
  statement {
    actions   = ["sts:GetWebIdentityToken"]
    resources = ["*"]

    condition {
      test     = "ForAllValues:StringEquals"
      variable = "sts:IdentityTokenAudience"
      values   = ["https:${data.terraform_remote_state.gcp.outputs.pageviewinfoga_audience}"]
    }

    # Google accepts RS256 and ES256 only
    condition {
      test     = "StringEquals"
      variable = "sts:SigningAlgorithm"
      values   = ["RS256"]
    }

    condition {
      test     = "NumericLessThanEquals"
      variable = "sts:DurationSeconds"
      values   = ["3600"]
    }
  }
}

#
# Policy documents for inline policies
#

data "aws_iam_policy_document" "ses_sending_access" {
  statement {
    actions   = ["ses:SendRawEmail"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "github_lambda" {
  statement {
    actions = [
      "lambda:UpdateFunctionCode",
      "lambda:UpdateFunctionConfiguration",
      "lambda:GetFunctionConfiguration",
    ]
    resources = [
      aws_lambda_function.mastodon_discord.arn,
      aws_lambda_function.mastodon_boost.arn,
      aws_lambda_function.grafana_github.arn,
      aws_lambda_function.sns_discord.arn,
      aws_lambda_function.bounce_handler.arn,
    ]
  }
}

data "aws_iam_policy_document" "femiwiki_github_io" {
  statement {
    actions = [
      "ce:GetCostAndUsage",
      "billing:GetCreditAllocationHistory",
      "billing:GetCredits",
      "cloudwatch:GetMetricData",
      "ec2:DescribeInstances",
      "invoicing:GetInvoicePDF",
      "invoicing:ListInvoiceSummaries",
      "route53:ListHealthChecks",
    ]
    resources = ["*"]
  }

  # Both buckets until bill-from-export.sh reads the Seoul one (femiwiki/femiwiki#667).
  statement {
    actions = ["s3:GetObject", "s3:ListBucket"]
    resources = [
      aws_s3_bucket.cost_and_usage.arn,
      "${aws_s3_bucket.cost_and_usage.arn}/*",
      aws_s3_bucket.cost_exports.arn,
      "${aws_s3_bucket.cost_exports.arn}/*",
    ]
  }
}

data "aws_iam_policy_document" "iac" {
  statement {
    actions = [
      "acm:*",
      "athena:*",
      "autoscaling:*",
      "bcm-data-exports:*",
      "budgets:*",
      "cloudfront:*",
      "cloudwatch:*",
      "cur:*",
      "ec2:*",
      "elasticloadbalancing:*",
      "events:*",
      "glue:*",
      "iam:*",
      "lambda:*",
      "logs:*",
      "route53:*",
      "route53domains:*",
      "s3:*",
      "ses:*",
      "sns:*",
      "sqs:*",
      "ssm:*",
      "sso:*",
      "tag:GetResources",
    ]
    resources = ["*"]
  }

  statement {
    actions   = ["iam:CreateServiceLinkedRole"]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "iam:AWSServiceName"
      values = [
        "autoscaling.amazonaws.com",
        "ec2scheduled.amazonaws.com",
        "elasticloadbalancing.amazonaws.com",
        "spot.amazonaws.com",
        "spotfleet.amazonaws.com",
        "transitgateway.amazonaws.com"
      ]
    }
  }
}

data "aws_iam_policy_document" "infra_grafana" {
  statement {
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.tfstate.arn]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = ["grafana/*"]
    }
  }

  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = ["${aws_s3_bucket.tfstate.arn}/grafana/*"]
  }

  # For the grafana-github function URL in the aws outputs.
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.tfstate.arn}/aws/terraform.tfstate"]
  }
}

data "aws_iam_policy_document" "infra_healthchecks" {
  statement {
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.tfstate.arn]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = ["healthchecks/*"]
    }
  }

  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = ["${aws_s3_bucket.tfstate.arn}/healthchecks/*"]
  }
}

