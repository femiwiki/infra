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
}

data "aws_iam_policy_document" "amazon_s3_access" {
  statement {
    actions = ["s3:*"]
    resources = [
      "${local.uploaded_files}/*",
      "${local.uploaded_files_thumb}/*",
      "${local.uploaded_files_temp}/*",
      "${local.uploaded_files_deleted}/*",
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
    resources = ["${local.secrets}"]
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

data "aws_iam_policy_document" "iac" {
  statement {
    actions = [
      "autoscaling:*",
      "cloudwatch:*",
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
