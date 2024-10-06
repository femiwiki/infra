output "nomad_addr" {
  description = "Address to our nomad cluster"
  value       = "http://${aws_instance.femiwiki.public_ip}:4646"
}

output "test_nomad_addr" {
  description = "Address to our nomad cluster"
  value       = aws_eip.test_femiwiki.public_ip
}

output "ebs_mysql_id" {
  value = aws_ebs_volume.persistent_data_mysql.id
}

output "ebs_caddycerts_id" {
  value = aws_ebs_volume.persistent_data_caddycerts.id
}
