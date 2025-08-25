output "blue_public_ip" {
  value = aws_eip.femiwiki_blue_eip.public_ip
}

output "client_ca_cert_pem" {
  value = trimspace(tls_self_signed_cert.ca_cert.cert_pem)
}

output "client_cert_pem" {
  value = trimspace(tls_locally_signed_cert.client_cert.cert_pem)
}

output "client_key_pem" {
  value     = trimspace(tls_private_key.client_key.private_key_pem)
  sensitive = true
}
