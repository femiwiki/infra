resource "aws_iam_user_policy" "femiwiki-email_AmazonSesSendingAccess" {
  name = "AmazonSesSendingAccess"

  policy = <<POLICY
{
  "Statement": [
    {
      "Action": "ses:SendRawEmail",
      "Effect": "Allow",
      "Resource": "*"
    }
  ],
  "Version": "2012-10-17"
}
POLICY

  user = "femiwiki-email"
}
