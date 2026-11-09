resource "terraform_data" "mediawiki_certificate_generation" {
  input = local.fastcgi_generation
}

resource "tls_private_key" "mediawiki" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"

  lifecycle {
    replace_triggered_by = [terraform_data.mediawiki_certificate_generation]
  }
}

resource "tls_cert_request" "mediawiki" {
  private_key_pem = tls_private_key.mediawiki.private_key_pem

  subject {
    organization = "Femiwiki"
    common_name  = "mediawiki"
  }
}

resource "tls_locally_signed_cert" "mediawiki" {
  cert_request_pem      = tls_cert_request.mediawiki.cert_request_pem
  ca_private_key_pem    = data.terraform_remote_state.aws.outputs.roles_anywhere_ca_private_key_pem
  ca_cert_pem           = data.terraform_remote_state.aws.outputs.roles_anywhere_ca_cert_pem
  validity_period_hours = 2160
  allowed_uses          = ["digital_signature"]
}

locals {
  roles_anywhere_dir = "/etc/aws-roles-anywhere"
}
