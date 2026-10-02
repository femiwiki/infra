import {
  to = aws_ssoadmin_permission_set.administrator_access
  id = "arn:aws:sso:::permissionSet/ssoins-723078109ea304b8/ps-3161492d98226b72,arn:aws:sso:::instance/ssoins-723078109ea304b8"
}

resource "aws_ssoadmin_permission_set" "administrator_access" {
  name             = "AdministratorAccess"
  instance_arn     = "arn:aws:sso:::instance/ssoins-723078109ea304b8"
  session_duration = "PT12H"
}
