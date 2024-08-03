resource "aws_ses_domain_identity" "femiwiki_com" {
  provider = aws.us
  domain   = "femiwiki.com"
}

resource "aws_ses_domain_dkim" "femiwiki_com" {
  provider = aws.us
  domain   = aws_ses_domain_identity.femiwiki_com.domain
}

resource "aws_ses_email_identity" "admin" {
  provider = aws.us
  email    = "admin@femiwiki.com"
}

# ref femiwiki/femiwiki#365 ("AWS SES Return-Path 도메인 설정")
resource "aws_ses_domain_mail_from" "femiwiki_com" {
  provider         = aws.us
  domain           = aws_ses_domain_identity.femiwiki_com.domain
  mail_from_domain = "bounce.${aws_ses_domain_identity.femiwiki_com.domain}"
}
