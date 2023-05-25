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

resource "aws_route53_record" "test_femiwiki_com" {
  name    = "test.femiwiki.com"
  type    = "A"
  zone_id = aws_route53_zone.femiwiki_com.zone_id
  records = [aws_eip.test_femiwiki.public_ip]
  ttl     = 300
}

resource "aws_route53_record" "maintenance_femiwiki_com" {
  name    = "maintenance.femiwiki.com"
  type    = "CNAME"
  zone_id = aws_route53_zone.femiwiki_com.zone_id
  ttl     = 300
  records = ["femiwiki.github.io"]
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

resource "aws_route53_record" "femiwiki_com_txt" {
  name    = "femiwiki.com"
  ttl     = 900
  type    = "TXT"
  zone_id = aws_route53_zone.femiwiki_com.zone_id
  records = [
    # Google Search Console
    "google-site-verification=dBkD96hFbYlBf5-GsXjjownJrAGYQvUIPHPK4T9Dwko",
    # Yandex Webmaster
    "yandex-verification: a457abccca159922",
    # SPF (ref femiwiki/femiwiki#172)
    "v=spf1 include:amazonses.com include:_spf.google.com include:mail.stibee.com ~all",
  ]
}

resource "aws_route53_record" "github_challenge_femiwiki_com" {
  name    = "_github-challenge-femiwiki.femiwiki.com"
  records = ["8116bea44c"]
  ttl     = 300
  type    = "TXT"
  zone_id = aws_route53_zone.femiwiki_com.zone_id
}

resource "aws_route53_record" "verifybing_femiwiki_com" {
  name    = "24475b093ea86d87f448bfcb0bbf50ee.femiwiki.com"
  type    = "CNAME"
  records = ["verify.bing.com"]
  ttl     = 900
  zone_id = aws_route53_zone.femiwiki_com.zone_id
}

resource "aws_route53_record" "stb_dkim_femiwiki_com" {
  name    = "stb._domainkey.femiwiki.com"
  type    = "CNAME"
  records = ["dkim.stibee.com"]
  ttl     = 3600
  zone_id = aws_route53_zone.femiwiki_com.zone_id
}

resource "aws_route53_record" "google_dkim_femiwiki_com" {
  name    = "google._domainkey.femiwiki.com"
  type    = "TXT"
  records = ["v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAqkwdgQSLbba/NEub8/uugKIyF/j/gv9wT+U4vmO33hKPIZ750BxoEf1jX36zbsYCkD1dXRj7KxNQdAXzGBf30KFlSthy+qeWBby3ISea//Z/dMgEUYjGkVOTqITJVRxj7uBROpKZo2Z8pNRlRZWVIIarYLNJv8UprJRXrKclGg\"\"5vrZh7R0/OK3k8MkaIX0zEIDhtr0lpbp16hUZynij/j+hES2N+IKYuYMp7Nl9RRQFgk52OKxZMTUdLkynSiWtpyvgqrWez4d6imWodsxm5xqL9ax3hleRv7MWj+xy9GBZ6gXgt9EC3MTTLzLOVYS+FPLfA6DI+Zd2DGA2Bn/fg1QIDAQAB"]
  ttl     = 3600
  zone_id = aws_route53_zone.femiwiki_com.zone_id
}

resource "aws_route53_health_check" "femiwiki_main_page" {
  fqdn              = "femiwiki.com"
  port              = 443
  type              = "HTTPS"
  failure_threshold = 3
  measure_latency   = true
  request_interval  = 30
  resource_path     = "/w/%ED%8E%98%EB%AF%B8%EC%9C%84%ED%82%A4:%EB%8C%80%EB%AC%B8"

  tags = {
    "Name" = "Femiwiki Main Page"
  }
}
