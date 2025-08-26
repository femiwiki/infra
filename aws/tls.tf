resource "tls_private_key" "ca_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "ca_cert" {
  private_key_pem = tls_private_key.ca_key.private_key_pem

  subject {
    common_name  = "Docker CA"
    organization = "Femiwiki"
  }

  validity_period_hours = 8760 # 1 year
  is_ca_certificate     = true
  allowed_uses = [
    "cert_signing",
    "crl_signing",
  ]
}

resource "tls_private_key" "server_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_cert_request" "server_csr" {
  private_key_pem = tls_private_key.server_key.private_key_pem

  subject {
    common_name  = "Docker Server"
    organization = "Femiwiki"
  }
  ip_addresses = [aws_eip.test_femiwiki.public_ip]
}

resource "tls_locally_signed_cert" "server_cert" {
  cert_request_pem = tls_cert_request.server_csr.cert_request_pem

  ca_private_key_pem = tls_private_key.ca_key.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca_cert.cert_pem

  validity_period_hours = 8760
  allowed_uses = [
    "server_auth",
  ]
}

resource "tls_private_key" "client_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_cert_request" "client_csr" {
  private_key_pem = tls_private_key.client_key.private_key_pem

  subject {
    common_name  = "Docker Client"
    organization = "Femiwiki"
  }
}

resource "tls_locally_signed_cert" "client_cert" {
  cert_request_pem = tls_cert_request.client_csr.cert_request_pem

  ca_private_key_pem = tls_private_key.ca_key.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca_cert.cert_pem

  validity_period_hours = 8760
  allowed_uses = [
    "client_auth",
  ]
}
