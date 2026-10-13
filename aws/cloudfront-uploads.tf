# upload.femiwiki.com, the uploads bucket behind CloudFront, so the bucket can
# stop allowing anonymous reads. femiwiki/femiwiki#237 has the steps.

locals {
  uploads_alias = "upload.femiwiki.com"
}

# Its own certificate rather than a name added to femiwiki_com's, which would
# replace the certificate the site is served with.
resource "aws_acm_certificate" "uploads" {
  region            = "us-east-1"
  domain_name       = local.uploads_alias
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "uploads_acm_validation" {
  name            = one(aws_acm_certificate.uploads.domain_validation_options).resource_record_name
  type            = one(aws_acm_certificate.uploads.domain_validation_options).resource_record_type
  zone_id         = aws_route53_zone.femiwiki_com.zone_id
  records         = [one(aws_acm_certificate.uploads.domain_validation_options).resource_record_value]
  ttl             = 300
  allow_overwrite = true
}

resource "aws_acm_certificate_validation" "uploads" {
  region                  = "us-east-1"
  certificate_arn         = aws_acm_certificate.uploads.arn
  validation_record_fqdns = [aws_route53_record.uploads_acm_validation.fqdn]
}

resource "aws_cloudfront_origin_access_control" "uploads" {
  name                              = "uploads"
  description                       = "upload.femiwiki.com reading the uploads bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# Objects carry no Cache-Control, and a re-upload keeps the URL of the original
# and its thumbnails, so an hour is how long a replaced image can stay old at
# an edge. The query string stays in the key, so a new one fetches afresh.
resource "aws_cloudfront_cache_policy" "uploads" {
  name        = "femiwiki-uploads"
  min_ttl     = 0
  default_ttl = 3600
  max_ttl     = 31536000

  parameters_in_cache_key_and_forwarded_to_origin {
    enable_accept_encoding_gzip   = true
    enable_accept_encoding_brotli = true

    cookies_config {
      cookie_behavior = "none"
    }
    headers_config {
      header_behavior = "none"
    }
    query_strings_config {
      query_string_behavior = "all"
    }
  }
}

resource "aws_cloudfront_distribution" "uploads" {
  enabled         = true
  comment         = "upload.femiwiki.com, the uploads bucket"
  aliases         = [local.uploads_alias]
  http_version    = "http2and3"
  is_ipv6_enabled = true
  # The same as femiwiki_com, for edges in Korea and Japan
  price_class = "PriceClass_200"

  origin {
    origin_id                = "uploads"
    domain_name              = aws_s3_bucket.uploads_seoul.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.uploads.id
  }

  default_cache_behavior {
    target_origin_id       = "uploads"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    cache_policy_id        = aws_cloudfront_cache_policy.uploads.id
    compress               = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.uploads.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}

resource "aws_route53_record" "uploads" {
  for_each = toset(["A", "AAAA"])

  name    = local.uploads_alias
  type    = each.key
  zone_id = aws_route53_zone.femiwiki_com.zone_id

  alias {
    name                   = aws_cloudfront_distribution.uploads.domain_name
    zone_id                = aws_cloudfront_distribution.uploads.hosted_zone_id
    evaluate_target_health = false
  }
}
