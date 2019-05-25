resource "aws_iam_role_policy" "UploadBackup_UploadBackup" {
  name = "UploadBackup"

  policy = <<POLICY
{
  "Statement": [
    {
      "Action": "s3:PutObject",
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::femiwiki-backups/mysql/*",
      "Sid": "VisualEditor0"
    }
  ],
  "Version": "2012-10-17"
}
POLICY

  role = "UploadBackup"
}
