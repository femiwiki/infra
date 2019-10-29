locals {
  admins = [
    "gmlthak12",
    "gwiyomisaranghae",
    "damdam",
    "Nagyeop",
    "simnalamburt",
  ]
}

resource "aws_iam_group" "admin" {
  name = "Admin"
  path = "/"
}

resource "aws_iam_group_policy_attachment" "administrator_access" {
  group = "Admin"
  # AWS managed policy
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_user" "admins" {
  for_each = toset(concat(local.admins, [
    "femiwiki-email",
    "packer",
  ]))

  name = each.key
  path = "/"
}

resource "aws_iam_user_group_membership" "admins" {
  for_each = toset(local.admins)

  user   = each.key
  groups = ["Admin"]
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "mediawiki" {
  name               = "MediaWiki"
  description        = "Allows EC2 instances to call AWS services on your behalf."
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "amazon_s3_access" {
  role       = aws_iam_role.mediawiki.name
  policy_arn = aws_iam_policy.amazon_s3_access.arn
}

data "aws_iam_policy_document" "amazon_s3_access" {
  statement {
    actions = ["s3:*"]
    resources = [
      "${aws_s3_bucket.uploaded_files.arn}/*",
      "${aws_s3_bucket.uploaded_files_thumb.arn}/*",
      "${aws_s3_bucket.uploaded_files_temp.arn}/*",
      "${aws_s3_bucket.uploaded_files_deleted.arn}/*",
    ]
  }

  statement {
    actions = [
      "s3:Get*",
      "s3:List*"
    ]
    resources = [
      aws_s3_bucket.uploaded_files.arn,
      aws_s3_bucket.uploaded_files_thumb.arn,
      aws_s3_bucket.uploaded_files_temp.arn,
      aws_s3_bucket.uploaded_files_deleted.arn
    ]
  }
}

resource "aws_iam_policy" "amazon_s3_access" {
  name        = "AmazonS3Access"
  description = "Provide Access to Amazon S3 buckets."

  policy = data.aws_iam_policy_document.amazon_s3_access.json
}

resource "aws_iam_role_policy_attachment" "route53" {
  role       = aws_iam_role.mediawiki.name
  policy_arn = aws_iam_policy.route53.arn
}

data "aws_iam_policy_document" "route53" {
  statement {
    actions = [
      "route53:GetHostedZone",
      "route53:ListResourceRecordSets",
      "route53:ChangeResourceRecordSets",
    ]
    resources = ["arn:aws:route53:::hostedzone/${aws_route53_zone.femiwiki_com.zone_id}"]
  }

  statement {
    actions = [
      "route53:GetChange",
    ]
    resources = ["arn:aws:route53:::change/*"]
  }
}

resource "aws_iam_policy" "route53" {
  name        = "Route53Access"
  description = "Provide Access to route53."

  policy = data.aws_iam_policy_document.route53.json
}

resource "aws_iam_group_policy_attachment" "force_mfa" {
  group = "Admin"
  policy_arn = aws_iam_policy.force_mfa.arn
}

resource "aws_iam_policy" "force_mfa" {
  name        = "Force_MFA"
  description = "This policy allows users to manage their own passwords and MFA devices but nothing else unless they authenticate with MFA."
  path        = "/"

  policy = data.aws_iam_policy_document.force_mfa.json
}

data "aws_iam_policy_document" "force_mfa" {
  statement {
    actions = [
      "iam:ListAccountAliases",
      "iam:ListUsers",
      "iam:ListVirtualMFADevices",
      "iam:GetAccountPasswordPolicy",
      "iam:GetAccountSummary"
    ]
    resources = ["*"]
    sid       = "AllowAllUsersToListAccounts"
  }

  statement {
    actions = [
      "iam:ChangePassword",
      "iam:CreateAccessKey",
      "iam:CreateLoginProfile",
      "iam:DeleteAccessKey",
      "iam:DeleteLoginProfile",
      "iam:GetLoginProfile",
      "iam:ListAccessKeys",
      "iam:UpdateAccessKey",
      "iam:UpdateLoginProfile",
      "iam:ListSigningCertificates",
      "iam:DeleteSigningCertificate",
      "iam:UpdateSigningCertificate",
      "iam:UploadSigningCertificate",
      "iam:ListSSHPublicKeys",
      "iam:GetSSHPublicKey",
      "iam:DeleteSSHPublicKey",
      "iam:UpdateSSHPublicKey",
      "iam:UploadSSHPublicKey"
    ]
    resources = ["arn:aws:iam::*:user/$${aws:username}"]
    sid       = "AllowIndividualUserToSeeAndManageOnlyTheirOwnAccountInformation"
  }

  statement {
    actions = [
      "iam:CreateVirtualMFADevice",
      "iam:DeleteVirtualMFADevice",
      "iam:EnableMFADevice",
      "iam:ListMFADevices",
      "iam:ResyncMFADevice"
    ]
    resources = [
      "arn:aws:iam::*:mfa/$${aws:username}",
      "arn:aws:iam::*:user/$${aws:username}",
    ]
    sid = "AllowIndividualUserToViewAndManageTheirOwnMFA"
  }

  statement {
    actions = ["iam:DeactivateMFADevice"]

    condition {
      test     = "Bool"
      variable = "aws:MultiFactorAuthPresent"
      values   = [true]
    }
    resources = [
      "arn:aws:iam::*:mfa/$${aws:username}",
      "arn:aws:iam::*:user/$${aws:username}",
    ]
    sid = "AllowIndividualUserToDeactivateOnlyTheirOwnMFAOnlyWhenUsingMFA"
  }

  statement {
    effect = "Deny"
    not_actions = [
      "iam:CreateVirtualMFADevice",
      "iam:DeleteVirtualMFADevice",
      "iam:ListVirtualMFADevices",
      "iam:EnableMFADevice",
      "iam:ResyncMFADevice",
      "iam:ListAccountAliases",
      "iam:ListUsers",
      "iam:ListSSHPublicKeys",
      "iam:ListAccessKeys",
      "iam:ListServiceSpecificCredentials",
      "iam:ListMFADevices",
      "iam:GetAccountSummary",
      "sts:GetSessionToken"
    ]
    resources = ["*"]
    sid       = "BlockMostAccessUnlessSignedInWithMFA"

    condition {
      test     = "BoolIfExists"
      variable = "aws:MultiFactorAuthPresent"
      values   = [false]
    }
  }
}

resource "aws_iam_role" "upload_backup" {
  name               = "UploadBackup"
  description        = "Allows EC2 instances to upload to the backup bucket."
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "upload_backup" {
  statement {
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.backups.arn}/*"]
  }
}

resource "aws_iam_user_policy_attachment" "packer" {
  user       = "packer"
  policy_arn = aws_iam_policy.packer.arn
}

data "aws_iam_policy_document" "packer" {
  statement {
    actions = [
      "ec2:AttachVolume",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:CopyImage",
      "ec2:CreateImage",
      "ec2:CreateKeypair",
      "ec2:CreateSecurityGroup",
      "ec2:CreateSnapshot",
      "ec2:CreateTags",
      "ec2:CreateVolume",
      "ec2:DeleteKeyPair",
      "ec2:DeleteSecurityGroup",
      "ec2:DeleteSnapshot",
      "ec2:DeleteVolume",
      "ec2:DeregisterImage",
      "ec2:DescribeImageAttribute",
      "ec2:DescribeImages",
      "ec2:DescribeInstances",
      "ec2:DescribeRegions",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSnapshots",
      "ec2:DescribeSubnets",
      "ec2:DescribeTags",
      "ec2:DescribeVolumes",
      "ec2:DetachVolume",
      "ec2:GetPasswordData",
      "ec2:ModifyImageAttribute",
      "ec2:ModifyInstanceAttribute",
      "ec2:ModifySnapshotAttribute",
      "ec2:RegisterImage",
      "ec2:RunInstances",
      "ec2:StopInstances",
      "ec2:TerminateInstances",
      "ec2:RequestSpotInstances",
      "ec2:CancelSpotInstanceRequests",
      "ec2:DescribeSpotInstanceRequests",
      "ec2:DescribeSpotPriceHistory"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "packer" {
  name        = "Packer"
  description = "Policy for packer"
  path        = "/"
  policy      = data.aws_iam_policy_document.packer.json
}

resource "aws_iam_role_policy_attachment" "elastic_loadbalancing_service" {
  role = "AWSServiceRoleForElasticLoadBalancing"
  # AWS managed policy
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AWSElasticLoadBalancingServiceRolePolicy"
}

resource "aws_iam_role_policy_attachment" "trusted_advisor_service" {
  role = "AWSServiceRoleForTrustedAdvisor"
  # AWS managed policy
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AWSTrustedAdvisorServiceRolePolicy"
}

data "aws_iam_policy_document" "ses_sending_access" {
  statement {
    actions   = ["ses:SendRawEmail"]
    resources = ["*"]
  }
}

resource "aws_iam_user_policy" "ses_sending_access" {
  name   = "AmazonSesSendingAccess"
  user   = "femiwiki-email"
  policy = data.aws_iam_policy_document.ses_sending_access.json
}
