data "aws_ssm_parameters_by_path" "mysql" {
  path      = "/mysql/"
  recursive = true
}

data "aws_ssm_parameters_by_path" "mediawiki" {
  path      = "/mediawiki/"
  recursive = true
}
