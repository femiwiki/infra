output "nomad_addr" {
  description = "Address to our nomad cluster"
  value       = "http://${aws_instance.femiwiki.public_ip}:4646"
}

output "nomad_private_ip" {
  description = "Address to our nomad cluster"
  value       = aws_instance.femiwiki.private_ip
}

output "test_nomad_public_ip" {
  description = "Address to our nomad cluster"
  value       = aws_eip.test_femiwiki.public_ip
}

output "test_nomad_private_ip" {
  description = "Address to our nomad cluster"
  value       = aws_instance.femiwiki_green[0].public_ip
}

output "ebs_mysql_id" {
  value = aws_ebs_volume.persistent_data_mysql.id
}

output "ebs_caddycerts_id" {
  value = aws_ebs_volume.persistent_data_caddycerts.id
}

output "ebs_caddycerts_green_id" {
  value = aws_ebs_volume.persistent_data_caddycerts_green.id
}
