import {
  to = aws_ssoadmin_permission_set.administrator_access
  id = "arn:aws:sso:::permissionSet/ssoins-723078109ea304b8/ps-3161492d98226b72,arn:aws:sso:::instance/ssoins-723078109ea304b8"
}

resource "aws_ssoadmin_permission_set" "administrator_access" {
  name             = "AdministratorAccess"
  instance_arn     = "arn:aws:sso:::instance/ssoins-723078109ea304b8"
  session_duration = "PT12H"
}

# Read-only access for Claude Code cloud sessions. lens0021 signs in with this
# permission set and hands the short-lived SSO token to the cloud environment,
# so a leaked token can look at the account but cannot change it or read data.
resource "aws_ssoadmin_permission_set" "claude_read_only" {
  name             = "ClaudeReadOnly"
  description      = "Read-only access for Claude Code cloud sessions"
  instance_arn     = "arn:aws:sso:::instance/ssoins-723078109ea304b8"
  session_duration = "PT12H"
}

resource "aws_ssoadmin_managed_policy_attachment" "claude_read_only" {
  instance_arn       = aws_ssoadmin_permission_set.claude_read_only.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.claude_read_only.arn
  managed_policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# ReadOnlyAccess can also read stored data: database dumps and backups in S3,
# Parameter Store and Secrets Manager values, and anything KMS decrypts.
data "aws_iam_policy_document" "claude_read_only_deny_data" {
  statement {
    sid    = "DenyDataReads"
    effect = "Deny"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetObjectTorrent",
      "s3:GetObjectAttributes",
      "s3:GetObjectVersionAttributes",
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath",
      "ssm:GetParameterHistory",
      "secretsmanager:GetSecretValue",
      "secretsmanager:BatchGetSecretValue",
      "kms:Decrypt",
      "lambda:GetFunction",
      "ec2:GetPasswordData",
    ]
    resources = ["*"]
  }
}

resource "aws_ssoadmin_permission_set_inline_policy" "claude_read_only" {
  instance_arn       = aws_ssoadmin_permission_set.claude_read_only.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.claude_read_only.arn
  inline_policy      = data.aws_iam_policy_document.claude_read_only_deny_data.json
}

resource "aws_ssoadmin_account_assignment" "claude_read_only_lens0021" {
  instance_arn       = aws_ssoadmin_permission_set.claude_read_only.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.claude_read_only.arn
  principal_type     = "USER"
  # lens0021's IAM Identity Center user.
  principal_id = "3418fdcc-3071-70c6-9ed7-c3b4b61630fd"
  target_type  = "AWS_ACCOUNT"
  target_id    = "302617221463"
}
