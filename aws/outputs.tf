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
