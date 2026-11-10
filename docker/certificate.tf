resource "terraform_data" "roles_anywhere_certificate_generation" {
  input = local.fastcgi_generation
}

resource "tls_private_key" "roles_anywhere" {
  for_each    = toset(local.roles_anywhere_roles)
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"

  lifecycle {
    replace_triggered_by = [terraform_data.roles_anywhere_certificate_generation]
  }
}

resource "tls_cert_request" "roles_anywhere" {
  for_each        = toset(local.roles_anywhere_roles)
  private_key_pem = tls_private_key.roles_anywhere[each.key].private_key_pem

  subject {
    organization = "Femiwiki"
    common_name  = each.key
  }
}

resource "tls_locally_signed_cert" "roles_anywhere" {
  for_each              = toset(local.roles_anywhere_roles)
  cert_request_pem      = tls_cert_request.roles_anywhere[each.key].cert_request_pem
  ca_private_key_pem    = data.terraform_remote_state.aws.outputs.roles_anywhere_ca_private_key_pem
  ca_cert_pem           = data.terraform_remote_state.aws.outputs.roles_anywhere_ca_cert_pem
  validity_period_hours = 87600
  allowed_uses          = ["digital_signature"]
}

moved {
  from = terraform_data.mediawiki_certificate_generation
  to   = terraform_data.roles_anywhere_certificate_generation
}

moved {
  from = tls_private_key.mediawiki
  to   = tls_private_key.roles_anywhere["mediawiki"]
}

moved {
  from = tls_cert_request.mediawiki
  to   = tls_cert_request.roles_anywhere["mediawiki"]
}

moved {
  from = tls_locally_signed_cert.mediawiki
  to   = tls_locally_signed_cert.roles_anywhere["mediawiki"]
}

locals {
  roles_anywhere_roles = ["mediawiki", "caddy"]
  roles_anywhere_dir   = "/etc/aws-roles-anywhere"
  caddy_aws_credentials = join(" ", [
    "/usr/local/bin/aws_signing_helper", "credential-process",
    "--certificate", "${local.roles_anywhere_dir}/certificate.pem",
    "--private-key", "${local.roles_anywhere_dir}/private-key.pem",
    "--trust-anchor-arn", data.terraform_remote_state.aws.outputs.roles_anywhere_trust_anchor_arn,
    "--profile-arn", data.terraform_remote_state.aws.outputs.roles_anywhere_profile_arn,
    "--role-arn", data.terraform_remote_state.aws.outputs.caddy_role_arn,
    "--session-duration", "7200",
  ])
}
