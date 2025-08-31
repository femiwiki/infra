output "ssm_parameters_mysql" {
  value     = data.aws_ssm_parameters_by_path.mysql
  sensitive = true
}

output "ssm_parameters_mediawiki" {
  value     = data.aws_ssm_parameters_by_path.mediawiki
  sensitive = true
}

output "femiwiki_eip" {
  value = aws_eip.femiwiki.public_ip
}

output "test_femiwiki_eip" {
  value = aws_eip.test_femiwiki.public_ip
}

output "docker_host_eip" {
  value = aws_eip.test_femiwiki.public_ip
}

output "mysql_private_ip" {
  value = aws_instance.database.private_ip
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
