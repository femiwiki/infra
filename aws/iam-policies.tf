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
      // 본인 패스워드 관리 허용
      "iam:ListUsers",
      "iam:GetUser",
      "iam:ChangePassword",
      // 본인 액세스키 관리 허용
      "iam:CreateAccessKey",
      "iam:DeleteAccessKey",
      "iam:ListAccessKeys",
      "iam:UpdateAccessKey",
      // 본인 Signing Certificates 허용
      "iam:ListSigningCertificates",
      "iam:DeleteSigningCertificate",
      "iam:UpdateSigningCertificate",
      "iam:UploadSigningCertificate",
      // 본인 SSH 공개키 관리 허용
      "iam:ListSSHPublicKeys",
      "iam:GetSSHPublicKey",
      "iam:DeleteSSHPublicKey",
      "iam:UpdateSSHPublicKey",
      "iam:UploadSSHPublicKey",
      // 본인 Service Specific Credential 관리 허용
      "iam:CreateServiceSpecificCredential",
      "iam:DeleteServiceSpecificCredential",
      "iam:ListServiceSpecificCredentials",
      "iam:ResetServiceSpecificCredential",
      "iam:UpdateServiceSpecificCredential",
      // 본인 MFA 관리 허용
      "iam:EnableMFADevice",
      "iam:ListMFADevices",
      "iam:ResyncMFADevice",
      "iam:DeactivateMFADevice",
    ]
    resources = ["arn:aws:iam::*:user/$${aws:username}"]
  }

  // 본인 VirtualMFA 관리 허용
  statement {
    sid = "AllowManageOwnVirtualMFADevice"
    actions = [
      "iam:CreateVirtualMFADevice",
      "iam:DeleteVirtualMFADevice",
    ]
    resources = ["arn:aws:iam::*:mfa/$${aws:username}"]
  }

  // MFA가 없는경우, 아래의 동작만 수행 가능
  statement {
    sid    = "DenyAllExceptListedIfNoMFA"
    effect = "Deny"
    not_actions = [
      // 비밀번호 변경 가능
      "iam:ListUsers",
      "iam:GetUser",
      "iam:ChangePassword",
      "iam:GetAccountPasswordPolicy",
      "sts:GetSessionToken",
      // VirtualMFA 관리 가능
      "iam:ListVirtualMFADevices",
      "iam:CreateVirtualMFADevice",
      "iam:DeleteVirtualMFADevice",
      // MFA 관리 가능
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
    actions = ["lambda:UpdateFunctionCode"]
    resources = [
      "arn:aws:lambda:ap-northeast-1:302617221463:function:DiscordNoti",
      "arn:aws:lambda:us-east-1:302617221463:function:DiscordNoti",
    ]
  }
}

data "aws_iam_policy_document" "terraform_cloud" {
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
      "ses:*",
      "sns:*",
      "sqs:*",
      "s3:*",
      "tag:GetResources"
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
