output "nomad_addr" {
  description = "Address to our nomad cluster"
  value       = "http://${aws_instance.femiwiki.public_ip}:4646"
}

output "test_nomad_addr" {
  description = "Address to our nomad cluster"
  value       = length(aws_instance.test_femiwiki) > 0 ? "http://${aws_instance.test_femiwiki[0].public_ip}:4646" : null
}

output "ebs_mysql_id" {
  value = aws_ebs_volume.persistent_data_mysql.id
}

output "ebs_caddycerts_id" {
  value = aws_ebs_volume.persistent_data_caddycerts.id
}
