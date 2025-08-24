output "blue_private_key_pem" {
  value     = tls_private_key.blue.private_key_pem
  sensitive = true
}

output "blue_ip" {
  value = aws_instance.femiwiki_blue.public_ip
}
