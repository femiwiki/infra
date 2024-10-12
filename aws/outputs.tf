output "nomad_blue_public_ip" {
  description = "Address to our nomad cluster"
  # placeholder
  value = aws_instance.femiwiki_green[0].public_ip
}

output "nomad_blue_private_ip" {
  description = "Address to our nomad cluster"
  # placeholder
  value = aws_instance.femiwiki_green[0].private_ip
}

output "nomad_green_public_ip" {
  description = "Address to our nomad cluster"
  value       = aws_instance.femiwiki_green[0].public_ip
}

output "nomad_green_private_ip" {
  description = "Address to our nomad cluster"
  value       = aws_instance.femiwiki_green[0].private_ip
}

output "ebs_mysql_id" {
  value = aws_ebs_volume.persistent_data_mysql.id
}

output "ebs_caddycerts_id" {
  value = aws_ebs_volume.persistent_data_caddycerts.id
}

output "ebs_caddycerts_green_id" {
  value = aws_ebs_volume.persistent_data_caddycerts.id
}
