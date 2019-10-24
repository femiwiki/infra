resource "aws_route53_record" "Z1IOLPZGUQYUUT__github-challenge-femiwiki--femiwiki--com--_TXT" {
  name    = "_github-challenge-femiwiki.femiwiki.com"
  records = ["8116bea44c"]
  ttl     = "300"
  type    = "TXT"
  zone_id = "${aws_route53_zone.Z1IOLPZGUQYUUT_femiwiki--com.zone_id}"
}

resource "aws_route53_record" "Z1IOLPZGUQYUUT_femiwiki--com--_MX" {
  name    = "femiwiki.com"
  records = ["1 ASPMX.L.GOOGLE.COM", "10 ALT3.ASPMX.L.GOOGLE.COM", "5 ALT1.ASPMX.L.GOOGLE.COM", "5 ALT2.ASPMX.L.GOOGLE.COM", "10 ALT4.ASPMX.L.GOOGLE.COM"]
  ttl     = "3600"
  type    = "MX"
  zone_id = "${aws_route53_zone.Z1IOLPZGUQYUUT_femiwiki--com.zone_id}"
}

resource "aws_route53_record" "Z1IOLPZGUQYUUT_femiwiki--com--_NS" {
  name    = "femiwiki.com"
  records = ["ns-788.awsdns-34.net.", "ns-287.awsdns-35.com.", "ns-1810.awsdns-34.co.uk.", "ns-1320.awsdns-37.org."]
  ttl     = "172800"
  type    = "NS"
  zone_id = "${aws_route53_zone.Z1IOLPZGUQYUUT_femiwiki--com.zone_id}"
}

resource "aws_route53_record" "Z1IOLPZGUQYUUT_femiwiki--com--_SOA" {
  name    = "femiwiki.com"
  records = ["ns-1320.awsdns-37.org. awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400"]
  ttl     = "900"
  type    = "SOA"
  zone_id = "${aws_route53_zone.Z1IOLPZGUQYUUT_femiwiki--com.zone_id}"
}
