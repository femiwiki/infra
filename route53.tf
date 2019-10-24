resource "aws_route53_zone" "femiwiki_com" {
  force_destroy = false
  name          = "femiwiki.com."
}

resource "aws_route53_record" "femiwiki_com_amazonses_verification_record" {
  name    = "_amazonses.femiwiki.com"
  records = [aws_ses_domain_identity.femiwiki_com.verification_token]
  ttl     = "1800"
  type    = "TXT"
  zone_id = aws_route53_zone.femiwiki_com.zone_id
}

resource "aws_route53_record" "amazonses_femiwiki_com_dkim_record" {
  count   = length(aws_ses_domain_dkim.femiwiki_com.dkim_tokens)
  zone_id = aws_route53_zone.femiwiki_com.zone_id
  name    = "${element(aws_ses_domain_dkim.femiwiki_com.dkim_tokens, count.index)}._domainkey.femiwiki.com"
  type    = "CNAME"
  ttl     = "300"
  records = ["${element(aws_ses_domain_dkim.femiwiki_com.dkim_tokens, count.index)}.dkim.amazonses.com"]
}
