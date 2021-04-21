output "nomad_addr" {
  description = "Address to our nomad cluster"
  value       = "http://${aws_instance.femiwiki_arm64.public_ip}:4646"
}

output "ebs_mysql_id" {
  value = aws_ebs_volume.persistent_data_mysql.id
}

output "ebs_caddycerts_id" {
  value = aws_ebs_volume.persistent_data_caddycerts.id
}
