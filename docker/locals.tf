locals {
  ssm_parameters_mediawiki = {
    for i, name in data.terraform_remote_state.aws.outputs.ssm_parameters_mediawiki.names :
    name => data.terraform_remote_state.aws.outputs.ssm_parameters_mediawiki.values[i]
  }
  ssm_parameters_mysql = {
    for i, name in data.terraform_remote_state.aws.outputs.ssm_parameters_mysql.names :
    name => data.terraform_remote_state.aws.outputs.ssm_parameters_mysql.values[i]
  }
}
