resource "aws_route53_record" "Z1IOLPZGUQYUUT_2yz4o5m6fz4fxc7menpiet2oh2iu34st--_domainkey--femiwiki--com--_CNAME" {
  name    = "2yz4o5m6fz4fxc7menpiet2oh2iu34st._domainkey.femiwiki.com"
  records = ["2yz4o5m6fz4fxc7menpiet2oh2iu34st.dkim.amazonses.com"]
  ttl     = "300"
  type    = "CNAME"
  zone_id = "${aws_route53_zone.Z1IOLPZGUQYUUT_femiwiki--com.zone_id}"
}

resource "aws_route53_record" "Z1IOLPZGUQYUUT_5ya44psrwmbbmja25vcpxrntycwpmyap--_domainkey--femiwiki--com--_CNAME" {
  name    = "5ya44psrwmbbmja25vcpxrntycwpmyap._domainkey.femiwiki.com"
  records = ["5ya44psrwmbbmja25vcpxrntycwpmyap.dkim.amazonses.com"]
  ttl     = "300"
  type    = "CNAME"
  zone_id = "${aws_route53_zone.Z1IOLPZGUQYUUT_femiwiki--com.zone_id}"
}

resource "aws_route53_record" "Z1IOLPZGUQYUUT__amazonses--femiwiki--com--_TXT" {
  name    = "_amazonses.femiwiki.com"
  records = ["TEXdrA8h0Su+KJl/dEp7Z6uWn2dbboiwQOhoZyb+jZQ="]
  ttl     = "1800"
  type    = "TXT"
  zone_id = "${aws_route53_zone.Z1IOLPZGUQYUUT_femiwiki--com.zone_id}"
}

resource "aws_route53_record" "Z1IOLPZGUQYUUT__bb27811814286f2e5b8472ccdab1ba34--femiwiki--com--_CNAME" {
  name    = "_bb27811814286f2e5b8472ccdab1ba34.femiwiki.com"
  records = ["_659b4aa0766f8e7ac67bb6cd3d40826d.tljzshvwok.acm-validations.aws."]
  ttl     = "300"
  type    = "CNAME"
  zone_id = "${aws_route53_zone.Z1IOLPZGUQYUUT_femiwiki--com.zone_id}"
}

resource "aws_route53_record" "Z1IOLPZGUQYUUT__github-challenge-femiwiki--femiwiki--com--_TXT" {
  name    = "_github-challenge-femiwiki.femiwiki.com"
  records = ["8116bea44c"]
  ttl     = "300"
  type    = "TXT"
  zone_id = "${aws_route53_zone.Z1IOLPZGUQYUUT_femiwiki--com.zone_id}"
}

resource "aws_route53_record" "Z1IOLPZGUQYUUT_adey3isneuqjaqsqibxsmqppfn33esg6--_domainkey--femiwiki--com--_CNAME" {
  name    = "adey3isneuqjaqsqibxsmqppfn33esg6._domainkey.femiwiki.com"
  records = ["adey3isneuqjaqsqibxsmqppfn33esg6.dkim.amazonses.com"]
  ttl     = "300"
  type    = "CNAME"
  zone_id = "${aws_route53_zone.Z1IOLPZGUQYUUT_femiwiki--com.zone_id}"
}

resource "aws_route53_record" "Z1IOLPZGUQYUUT_femiwiki--com--_A" {
  alias {
    evaluate_target_health = false
    name                   = "femiwiki-load-balancer-1016469507.ap-northeast-1.elb.amazonaws.com"
    zone_id                = "Z14GRHDCWA56QT"
  }

  name    = "femiwiki.com"
  type    = "A"
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

resource "aws_route53_record" "Z1IOLPZGUQYUUT_www--femiwiki--com--_A" {
  alias {
    evaluate_target_health = false
    name                   = "femiwiki-load-balancer-1016469507.ap-northeast-1.elb.amazonaws.com"
    zone_id                = "Z14GRHDCWA56QT"
  }

  name    = "www.femiwiki.com"
  type    = "A"
  zone_id = "${aws_route53_zone.Z1IOLPZGUQYUUT_femiwiki--com.zone_id}"
}
