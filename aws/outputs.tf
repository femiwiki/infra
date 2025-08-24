output "blue_identity_private_openssh" {
  value     = tls_private_key.blue.private_key_openssh
  sensitive = true
}

output "blue_ip" {
  value = aws_instance.femiwiki_blue.public_ip
}
