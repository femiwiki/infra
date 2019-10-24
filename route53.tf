resource "aws_route53_zone" "femiwiki_com" {
  force_destroy = false
  name          = "femiwiki.com."
}

resource "aws_route53_record" "femiwiki_com" {
  name    = "femiwiki.com"
  type    = "A"
  zone_id = aws_route53_zone.femiwiki_com.zone_id

  alias {
    name                   = aws_lb.femiwiki.dns_name
    zone_id                = aws_lb.femiwiki.zone_id
    evaluate_target_health = false
  }
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

resource "aws_route53_record" "femiwiki_com_acm" {
  name    = aws_acm_certificate.femiwiki_com.domain_validation_options[0].resource_record_name
  records = [aws_acm_certificate.femiwiki_com.domain_validation_options[0].resource_record_value]
  ttl     = "300"
  type    = "CNAME"
  zone_id = aws_route53_zone.femiwiki_com.zone_id
}
