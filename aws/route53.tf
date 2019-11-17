resource "aws_route53_zone" "femiwiki_com" {
  force_destroy = false
  name          = "femiwiki.com."
}

resource "aws_route53_record" "femiwiki_com" {
  name    = "femiwiki.com"
  type    = "A"
  zone_id = aws_route53_zone.femiwiki_com.zone_id
  records = [aws_eip.femiwiki.public_ip]
  ttl     = 300
}

resource "aws_route53_record" "www_femiwiki_com" {
  name    = "www.femiwiki.com"
  type    = "A"
  zone_id = aws_route53_zone.femiwiki_com.zone_id
  records = [aws_eip.femiwiki.public_ip]
  ttl     = 300
}

resource "aws_route53_record" "maintenance_femiwiki_com" {
  name    = "maintenance.femiwiki.com"
  type    = "CNAME"
  zone_id = aws_route53_zone.femiwiki_com.zone_id
  ttl     = 300
  records = ["femiwiki.github.io/maintenance"]
}

resource "aws_route53_record" "femiwiki_com_amazonses_verification_record" {
  name    = "_amazonses.femiwiki.com"
  records = [aws_ses_domain_identity.femiwiki_com.verification_token]
  ttl     = 1800
  type    = "TXT"
  zone_id = aws_route53_zone.femiwiki_com.zone_id
}

resource "aws_route53_record" "amazonses_femiwiki_com_dkim_record" {
  count   = length(aws_ses_domain_dkim.femiwiki_com.dkim_tokens)
  zone_id = aws_route53_zone.femiwiki_com.zone_id
  name    = "${element(aws_ses_domain_dkim.femiwiki_com.dkim_tokens, count.index)}._domainkey.femiwiki.com"
  type    = "CNAME"
  ttl     = 300
  records = ["${element(aws_ses_domain_dkim.femiwiki_com.dkim_tokens, count.index)}.dkim.amazonses.com"]
}

resource "aws_route53_record" "femiwiki_com_mx" {
  name = "femiwiki.com"
  records = [
    "1 ASPMX.L.GOOGLE.COM",
    "10 ALT3.ASPMX.L.GOOGLE.COM",
    "5 ALT1.ASPMX.L.GOOGLE.COM",
    "5 ALT2.ASPMX.L.GOOGLE.COM",
    "10 ALT4.ASPMX.L.GOOGLE.COM",
  ]
  ttl     = 3600
  type    = "MX"
  zone_id = aws_route53_zone.femiwiki_com.zone_id
}

resource "aws_route53_record" "femiwiki_com_ns" {
  name = "femiwiki.com"
  records = [
    "ns-788.awsdns-34.net.",
    "ns-287.awsdns-35.com.",
    "ns-1810.awsdns-34.co.uk.",
    "ns-1320.awsdns-37.org.",
  ]
  ttl     = 172800
  type    = "NS"
  zone_id = aws_route53_zone.femiwiki_com.zone_id
}

resource "aws_route53_record" "femiwiki_com_soa" {
  name    = "femiwiki.com"
  records = ["ns-1320.awsdns-37.org. awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400"]
  ttl     = 900
  type    = "SOA"
  zone_id = aws_route53_zone.femiwiki_com.zone_id
}

resource "aws_route53_record" "github_challenge_femiwiki_com" {
  name    = "_github-challenge-femiwiki.femiwiki.com"
  records = ["8116bea44c"]
  ttl     = 300
  type    = "TXT"
  zone_id = aws_route53_zone.femiwiki_com.zone_id
}
