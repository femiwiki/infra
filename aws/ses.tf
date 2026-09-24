resource "aws_ses_domain_identity" "femiwiki_com" {
  domain = "femiwiki.com"
  region = "us-east-1"
}

resource "aws_ses_domain_dkim" "femiwiki_com" {
  domain = aws_ses_domain_identity.femiwiki_com.domain
  region = "us-east-1"
}

resource "aws_ses_email_identity" "admin" {
  email  = "admin@femiwiki.com"
  region = "us-east-1"
}

# ref femiwiki/femiwiki#365 ("AWS SES Return-Path domain configuration")
resource "aws_ses_domain_mail_from" "femiwiki_com" {
  domain           = aws_ses_domain_identity.femiwiki_com.domain
  mail_from_domain = "bounce.${aws_ses_domain_identity.femiwiki_com.domain}"
  region           = "us-east-1"
}
