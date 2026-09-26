locals {
  parameter_store_regions = [data.aws_region.current.region, local.seoul_region]
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
  secrets                = aws_s3_bucket.secrets.arn
  uploaded_files         = aws_s3_bucket.uploaded_files.arn
  uploaded_files_thumb   = aws_s3_bucket.uploaded_files_thumb.arn
  uploaded_files_temp    = aws_s3_bucket.uploaded_files_temp.arn
  uploaded_files_deleted = aws_s3_bucket.uploaded_files_deleted.arn
  backups                = aws_s3_bucket.backups.arn
  uploads_seoul          = aws_s3_bucket.uploads_seoul.arn
}

data "aws_iam_policy_document" "amazon_s3_access" {
  statement {
    actions = ["s3:*"]
    resources = [
      "${local.uploaded_files}/*",
      "${local.uploaded_files_thumb}/*",
      "${local.uploaded_files_temp}/*",
      "${local.uploaded_files_deleted}/*",
      "${local.uploads_seoul}/*",
    ]
  }

  statement {
    actions = [
      "s3:Get*",
      "s3:List*"
    ]
    resources = [
      local.uploaded_files,
      local.uploaded_files_thumb,
      local.uploaded_files_temp,
      local.uploaded_files_deleted,
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

resource "aws_iam_policy" "download_secrets" {
  name        = "DownloadSecrets"
  description = "Allows to download secrets"

  policy = data.aws_iam_policy_document.download_secrets.json
}

data "aws_iam_policy_document" "download_secrets" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${local.secrets}/*"]
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
    resources = [local.secrets]
  }
  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = ["${local.secrets}/caddycerts/*"]
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
    resources = ["${local.backups}/*"]
  }
}

resource "aws_iam_policy" "read_backup" {
  name        = "ReadBackup"
  description = "Allows to read the MySQL backups back"

  policy = data.aws_iam_policy_document.read_backup.json
}

data "aws_iam_policy_document" "read_backup" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${local.backups}/mysql/*"]
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = [local.backups]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = ["mysql/*"]
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
      values   = ["ssm.${data.aws_region.current.region}.amazonaws.com"]
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
      "arn:aws:lambda:ap-northeast-1:302617221463:function:DiscordNoti",
      "arn:aws:lambda:us-east-1:302617221463:function:DiscordNoti",
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

  statement {
    actions   = ["s3:GetObject", "s3:ListBucket"]
    resources = [aws_s3_bucket.cost_exports.arn, "${aws_s3_bucket.cost_exports.arn}/*"]
  }
}

data "aws_iam_policy_document" "infra_docker" {
  statement {
    sid       = "State"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["${aws_s3_bucket.tfstate.arn}/docker/terraform.tfstate*"]
  }

  statement {
    sid       = "StateBucket"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.tfstate.arn]
  }

  statement {
    sid       = "FindInstances"
    actions   = ["ec2:DescribeInstances", "ec2:DescribeInstanceTypes"]
    resources = ["*"]
  }

  statement {
    sid     = "DockerPortForward"
    actions = ["ssm:StartSession"]
    resources = [
      aws_instance.docker.arn,
      "arn:aws:ssm:${data.aws_region.current.region}::document/AWS-StartPortForwardingSession",
    ]
  }

  statement {
    sid       = "OwnSessions"
    actions   = ["ssm:TerminateSession", "ssm:ResumeSession"]
    resources = ["arn:aws:ssm:*:*:session/$${aws:userid}-*"]
  }
}

data "aws_iam_policy_document" "discord_noti" {
  statement {
    actions = ["logs:CreateLogGroup"]
    resources = [
      aws_cloudwatch_log_group.discord_noti.arn,
      aws_cloudwatch_log_group.discord_noti_us.arn,
    ]
  }

  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      "${aws_cloudwatch_log_group.discord_noti.arn}:*",
      "${aws_cloudwatch_log_group.discord_noti_us.arn}:*",
    ]
  }

  statement {
    # GetMetricWidgetImage does not support resource-level permissions.
    actions   = ["cloudwatch:GetMetricWidgetImage"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "iac" {
  statement {
    actions = [
      "autoscaling:*",
      "bcm-data-exports:*",
      "budgets:*",
      "cloudwatch:*",
      "cur:*",
      "ec2:*",
      "elasticloadbalancing:*",
      "events:*",
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

data "aws_iam_policy_document" "backup_uploads" {
  statement {
    actions   = ["SNS:Publish"]
    resources = [aws_sns_topic.backup_uploads.arn]

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = [aws_s3_bucket.backups.arn]
    }
  }
}
