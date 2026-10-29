# CloudFront in front of femiwiki.com, caching only load.php, favicon.ico and the "/" redirect.
# femiwiki/femiwiki#639 has why, and the order for turning it on and off.

# The name CloudFront connects to. Only CloudFront resolves it, so a short TTL
# costs nothing and lets a new address take over within a minute.
resource "aws_route53_record" "cloudfront_origin" {
  name    = "cloudfront-origin.femiwiki.com"
  type    = "A"
  zone_id = aws_route53_zone.femiwiki_com.zone_id
  records = [aws_eip.web.public_ip]
  ttl     = 60
}

locals {
  cloudfront_aliases = ["femiwiki.com", "www.femiwiki.com", "fedi.femiwiki.com"]
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

data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}

resource "aws_cloudfront_cache_policy" "load_php" {
  name        = "femiwiki-load-php"
  min_ttl     = 0
  default_ttl = 0
  max_ttl     = 31536000 # the same as Managed-UseOriginCacheControlHeaders-QueryStrings

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

# MediaWiki's "/" redirect to the main page, per host. Session cookies are in
# the key, and 1200 is the s-maxage MediaWiki gives the redirect.
resource "aws_cloudfront_cache_policy" "root" {
  name        = "femiwiki-root"
  min_ttl     = 0
  default_ttl = 0
  max_ttl     = 1200

  parameters_in_cache_key_and_forwarded_to_origin {
    enable_accept_encoding_gzip   = true
    enable_accept_encoding_brotli = true

    cookies_config {
      cookie_behavior = "whitelist"
      cookies {
        items = ["femiwiki_session", "femiwikiUserID", "femiwikiToken"]
      }
    }
    headers_config {
      header_behavior = "whitelist"
      headers {
        items = ["Host"]
      }
    }
    query_strings_config {
      query_string_behavior = "all"
    }
  }
}

# Every viewer header, as Managed-AllViewer, and of the CloudFront-* headers,
# which would dominate every access log line, only the TLS fingerprint: a
# crawl can copy a browser's User-Agent and Sec-Fetch-* headers, but not its
# TLS handshake. Logged to tell readers from crawls that drain reader_clicks.
# CloudFront adds X-Forwarded-For whatever the policy says.
resource "aws_cloudfront_origin_request_policy" "all_viewer" {
  name    = "femiwiki-all-viewer"
  comment = "All viewer headers and the JA4 fingerprint"

  cookies_config {
    cookie_behavior = "all"
  }
  headers_config {
    header_behavior = "allViewerAndWhitelistCloudFront"
    headers {
      items = ["CloudFront-Viewer-JA4-Fingerprint"]
    }
  }
  query_strings_config {
    query_string_behavior = "all"
  }
}

locals {
  # The error codes CloudFront would otherwise cache for 10 seconds, even with
  # caching disabled. A crawler's 403 or the fallback's 503 must not reach the
  # next reader of the same URL.
  cloudfront_uncached_errors = [400, 403, 404, 405, 414, 416, 500, 501, 502, 503, 504]

  # Answered with femiwiki/maintenance's page under the same code. MediaWiki's
  # own 404 and 500 pages say more, and a 429 cannot be replaced at all.
  cloudfront_maintenance_errors = [502, 503, 504]
}

resource "aws_cloudfront_distribution" "femiwiki_com" {
  enabled         = true
  comment         = "femiwiki.com, caching only load.php, favicon.ico and the / redirect"
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

  # GitHub Pages of femiwiki/maintenance, away from the origin it stands in for
  origin {
    origin_id   = "maintenance"
    domain_name = "femiwiki.github.io"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id         = "femiwiki"
    viewer_protocol_policy   = "redirect-to-https"
    allowed_methods          = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods           = ["GET", "HEAD"]
    cache_policy_id          = data.aws_cloudfront_cache_policy.caching_disabled.id
    origin_request_policy_id = aws_cloudfront_origin_request_policy.all_viewer.id
    compress                 = true
  }

  ordered_cache_behavior {
    path_pattern             = "/"
    target_origin_id         = "femiwiki"
    viewer_protocol_policy   = "redirect-to-https"
    allowed_methods          = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods           = ["GET", "HEAD"]
    cache_policy_id          = aws_cloudfront_cache_policy.root.id
    origin_request_policy_id = aws_cloudfront_origin_request_policy.all_viewer.id
    compress                 = true
  }

  ordered_cache_behavior {
    path_pattern             = "/load.php"
    target_origin_id         = "femiwiki"
    viewer_protocol_policy   = "redirect-to-https"
    allowed_methods          = ["GET", "HEAD"]
    cached_methods           = ["GET", "HEAD"]
    cache_policy_id          = aws_cloudfront_cache_policy.load_php.id
    origin_request_policy_id = aws_cloudfront_origin_request_policy.all_viewer.id
    compress                 = true
  }

  ordered_cache_behavior {
    path_pattern             = "/favicon.ico"
    target_origin_id         = "femiwiki"
    viewer_protocol_policy   = "redirect-to-https"
    allowed_methods          = ["GET", "HEAD"]
    cached_methods           = ["GET", "HEAD"]
    cache_policy_id          = data.aws_cloudfront_cache_policy.caching_optimized.id
    origin_request_policy_id = aws_cloudfront_origin_request_policy.all_viewer.id
    compress                 = true
  }

  # No origin request policy, so Pages gets its own name as Host. Uncached, or
  # the URL that failed would keep the error page for the page's TTL.
  ordered_cache_behavior {
    path_pattern           = "/maintenance/*"
    target_origin_id       = "maintenance"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    cache_policy_id        = data.aws_cloudfront_cache_policy.caching_disabled.id
    compress               = true
  }

  dynamic "custom_error_response" {
    for_each = toset(local.cloudfront_uncached_errors)

    content {
      error_code            = custom_error_response.value
      error_caching_min_ttl = 0
      response_page_path    = contains(local.cloudfront_maintenance_errors, custom_error_response.value) ? "/maintenance/index.html" : null
      response_code         = contains(local.cloudfront_maintenance_errors, custom_error_response.value) ? tostring(custom_error_response.value) : null
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
