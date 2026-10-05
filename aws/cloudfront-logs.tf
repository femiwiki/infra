# Every request CloudFront answers, cache hits included, kept for 30 days:
# long enough for every investigation so far, which closed within days.
resource "aws_s3_bucket" "edge_logs_seoul" {
  region           = local.seoul_region
  bucket           = "edge-logs-${data.aws_caller_identity.current.account_id}-${local.seoul_region}-an"
  bucket_namespace = "account-regional"
}

resource "aws_s3_bucket_public_access_block" "edge_logs_seoul" {
  region = local.seoul_region
  bucket = aws_s3_bucket.edge_logs_seoul.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Expiry only: hourly Parquet files are under the 128 KB minimum of the
# infrequent-access classes, and transitions would cost more than they save.
resource "aws_s3_bucket_lifecycle_configuration" "edge_logs_seoul" {
  region = local.seoul_region
  bucket = aws_s3_bucket.edge_logs_seoul.id

  rule {
    id     = "expire-cloudfront-logs"
    status = "Enabled"

    filter {
      prefix = "cloudfront/"
    }

    expiration {
      days = 30
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }
  }
}

resource "aws_s3_bucket_policy" "edge_logs_seoul" {
  depends_on = [aws_s3_bucket_public_access_block.edge_logs_seoul]

  region = local.seoul_region
  bucket = aws_s3_bucket.edge_logs_seoul.id
  policy = data.aws_iam_policy_document.edge_logs_seoul.json
}

data "aws_iam_policy_document" "edge_logs_seoul" {
  statement {
    sid       = "DenyPlainHttp"
    effect    = "Deny"
    actions   = ["s3:*"]
    resources = [aws_s3_bucket.edge_logs_seoul.arn, "${aws_s3_bucket.edge_logs_seoul.arn}/*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }

  statement {
    sid       = "AWSLogDeliveryWrite"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.edge_logs_seoul.arn}/cloudfront/*"]

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:logs:us-east-1:${data.aws_caller_identity.current.account_id}:delivery-source:*"]
    }
  }

  statement {
    sid       = "AWSLogDeliveryAclCheck"
    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.edge_logs_seoul.arn]

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:logs:us-east-1:${data.aws_caller_identity.current.account_id}:delivery-source:*"]
    }
  }
}

# CloudFront's log delivery is configured in us-east-1 wherever the bucket is.
resource "aws_cloudwatch_log_delivery_source" "femiwiki_com" {
  region       = "us-east-1"
  name         = "femiwiki-com-access-logs"
  log_type     = "ACCESS_LOGS"
  resource_arn = aws_cloudfront_distribution.femiwiki_com.arn
}

resource "aws_cloudwatch_log_delivery_destination" "edge_logs_seoul" {
  region        = "us-east-1"
  name          = "edge-logs-seoul"
  output_format = "parquet"

  delivery_destination_configuration {
    destination_resource_arn = "${aws_s3_bucket.edge_logs_seoul.arn}/cloudfront"
  }
}

# No cs(Cookie): it carries session cookies. x-edge-request-id is the
# X-Amz-Cf-Id in Caddy's access log, for joining the two.
resource "aws_cloudwatch_log_delivery" "femiwiki_com" {
  depends_on = [aws_s3_bucket_policy.edge_logs_seoul]

  region                   = "us-east-1"
  delivery_source_name     = aws_cloudwatch_log_delivery_source.femiwiki_com.name
  delivery_destination_arn = aws_cloudwatch_log_delivery_destination.edge_logs_seoul.arn

  record_fields = [
    "date",
    "time",
    "x-edge-location",
    "asn",
    "c-country",
    "c-ip",
    "x-forwarded-for",
    "cs-method",
    "x-host-header",
    "cs-uri-stem",
    "cs-uri-query",
    "sc-status",
    "sc-bytes",
    "cs(Referer)",
    "cs(User-Agent)",
    "x-edge-result-type",
    "x-edge-response-result-type",
    "x-edge-detailed-result-type",
    "x-edge-request-id",
    "cs-protocol-version",
    "time-taken",
    "time-to-first-byte",
    "sc-content-type",
    "cache-behavior-path-pattern",
  ]

  s3_delivery_configuration {
    enable_hive_compatible_path = true
    suffix_path                 = "{yyyy}/{MM}/{dd}/{HH}"
  }
}
