resource "tls_private_key" "roles_anywhere_ca" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_self_signed_cert" "roles_anywhere_ca" {
  private_key_pem       = tls_private_key.roles_anywhere_ca.private_key_pem
  is_ca_certificate     = true
  validity_period_hours = 87600
  allowed_uses          = ["cert_signing", "crl_signing"]

  subject {
    organization = "Femiwiki"
    common_name  = "Femiwiki IAM Roles Anywhere"
  }
}

resource "aws_rolesanywhere_trust_anchor" "femiwiki" {
  name    = "femiwiki"
  enabled = true

  source {
    source_type = "CERTIFICATE_BUNDLE"
    source_data {
      x509_certificate_data = tls_self_signed_cert.roles_anywhere_ca.cert_pem
    }
  }
}

locals {
  roles_anywhere_trust = {
    for name in ["mediawiki"] : name => {
      RolesAnywhere = {
        actions    = ["sts:AssumeRole", "sts:TagSession", "sts:SetSourceIdentity"]
        principals = [{ type = "Service", identifiers = ["rolesanywhere.amazonaws.com"] }]
        condition = [
          {
            test     = "ArnEquals"
            variable = "aws:SourceArn"
            values   = [aws_rolesanywhere_trust_anchor.femiwiki.arn]
          },
          {
            test     = "StringEquals"
            variable = "aws:PrincipalTag/x509Subject/CN"
            values   = [name]
          },
        ]
      }
    }
  }
}

module "mediawiki" {
  source                   = "terraform-aws-modules/iam/aws//modules/iam-role"
  version                  = "6.8.2"
  name                     = "mediawiki"
  use_name_prefix          = false
  description              = "MediaWiki's containers, fastcgi and jobrunner, through IAM Roles Anywhere"
  trust_policy_permissions = local.roles_anywhere_trust["mediawiki"]
  policies = {
    amazon_s3_access          = aws_iam_policy.amazon_s3_access.arn
    read_mediawiki_parameters = aws_iam_policy.read_mediawiki_parameters.arn
    get_google_subject_token  = aws_iam_policy.get_google_subject_token.arn
  }
  max_session_duration = 7200
}

resource "aws_rolesanywhere_profile" "femiwiki" {
  name             = "femiwiki"
  enabled          = true
  duration_seconds = 7200
  role_arns        = [module.mediawiki.arn]
}
