# CloudFront in front of femiwiki.com, caching nothing, so that egress to
# readers leaves through CloudFront's free tier instead of the box's. Every
# request still reaches Caddy, and mwcache keeps handling PURGE. See
# femiwiki/femiwiki#639, whose "Keep it removable" section has the order for
# turning this on and off.

# The name CloudFront connects to. Only CloudFront resolves it, so a short TTL
# costs nothing and lets a new address take over within a minute.
resource "aws_route53_record" "cloudfront_origin" {
  name    = "cloudfront-origin.femiwiki.com"
  type    = "A"
  zone_id = aws_route53_zone.femiwiki_com.zone_id
  records = [aws_eip.seoul.public_ip]
  ttl     = 60
}

locals {
  cloudfront_aliases = ["femiwiki.com", "www.femiwiki.com"]
}

# A viewer certificate has to be in us-east-1. Caddy keeps its own for the
# origin leg. Names rather than a wildcard, so each has its own validation
# record and for_each can key on names known before apply.
resource "aws_acm_certificate" "femiwiki_com" {
  region                    = "us-east-1"
  domain_name               = local.cloudfront_aliases[0]
  subject_alternative_names = slice(local.cloudfront_aliases, 1, length(local.cloudfront_aliases))
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "femiwiki_com_acm_validation" {
  for_each = toset(local.cloudfront_aliases)

  name            = one([for o in aws_acm_certificate.femiwiki_com.domain_validation_options : o.resource_record_name if o.domain_name == each.key])
  type            = one([for o in aws_acm_certificate.femiwiki_com.domain_validation_options : o.resource_record_type if o.domain_name == each.key])
  zone_id         = aws_route53_zone.femiwiki_com.zone_id
  records         = [one([for o in aws_acm_certificate.femiwiki_com.domain_validation_options : o.resource_record_value if o.domain_name == each.key])]
  ttl             = 300
  allow_overwrite = true
}

resource "aws_acm_certificate_validation" "femiwiki_com" {
  region                  = "us-east-1"
  certificate_arn         = aws_acm_certificate.femiwiki_com.arn
  validation_record_fqdns = [for r in aws_route53_record.femiwiki_com_acm_validation : r.fqdn]
}

data "aws_cloudfront_cache_policy" "caching_disabled" {
  name = "Managed-CachingDisabled"
}

data "aws_cloudfront_origin_request_policy" "all_viewer" {
  name = "Managed-AllViewer"
}

locals {
  # The error codes CloudFront would otherwise cache for 10 seconds, even with
  # caching disabled. A crawler's 403 or the fallback's 503 must not reach the
  # next reader of the same URL.
  cloudfront_uncached_errors = [400, 403, 404, 405, 414, 416, 500, 501, 502, 503, 504]
}

resource "aws_cloudfront_distribution" "femiwiki_com" {
  enabled         = true
  comment         = "femiwiki.com, caching nothing"
  aliases         = local.cloudfront_aliases
  http_version    = "http2and3"
  is_ipv6_enabled = true
  # Includes Korea and Japan; PriceClass_100 would send Korean readers to
  # edges in North America or Europe
  price_class = "PriceClass_200"

  origin {
    origin_id   = "femiwiki"
    domain_name = aws_route53_record.cloudfront_origin.fqdn

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
      # The most CloudFront allows without a quota increase; php-fpm and
      # Caddy's queue can take longer than the default 30
      origin_read_timeout = 60
    }
  }

  default_cache_behavior {
    target_origin_id         = "femiwiki"
    viewer_protocol_policy   = "redirect-to-https"
    allowed_methods          = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods           = ["GET", "HEAD"]
    cache_policy_id          = data.aws_cloudfront_cache_policy.caching_disabled.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.all_viewer.id
    compress                 = true
  }

  dynamic "custom_error_response" {
    for_each = toset(local.cloudfront_uncached_errors)

    content {
      error_code            = custom_error_response.value
      error_caching_min_ttl = 0
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.femiwiki_com.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.femiwiki_com.domain_name
}
