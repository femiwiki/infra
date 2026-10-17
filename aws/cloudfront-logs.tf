# Every request CloudFront answers, cache hits included, kept for 30 days:
# long enough for every investigation so far, which closed within days.
module "edge_logs" {
  source                                = "terraform-aws-modules/s3-bucket/aws"
  version                               = "5.17.0"
  region                                = local.seoul_region
  bucket                                = "edge-logs-${data.aws_caller_identity.current.account_id}-${local.seoul_region}-an"
  bucket_namespace                      = "account-regional"
  attach_deny_insecure_transport_policy = true
  attach_policy                         = true
  policy                                = data.aws_iam_policy_document.edge_logs.json
  # Expiry only: hourly Parquet files are under the 128 KB minimum of the
  # infrequent-access classes, and transitions would cost more than they save.
  lifecycle_rule = [
    {
      id                                     = "expire-cloudfront-logs"
      enabled                                = true
      filter                                 = { prefix = "cloudfront/" }
      expiration                             = { days = 30 }
      abort_incomplete_multipart_upload_days = 1
    },
    {
      id         = "expire-athena-results"
      enabled    = true
      filter     = { prefix = "athena-results/" }
      expiration = { days = 7 }
    },
  ]
}

moved {
  from = aws_s3_bucket.edge_logs
  to   = module.edge_logs.aws_s3_bucket.this[0]
}

moved {
  from = aws_s3_bucket_public_access_block.edge_logs
  to   = module.edge_logs.aws_s3_bucket_public_access_block.this[0]
}

moved {
  from = aws_s3_bucket_lifecycle_configuration.edge_logs
  to   = module.edge_logs.aws_s3_bucket_lifecycle_configuration.this[0]
}

moved {
  from = aws_s3_bucket_policy.edge_logs
  to   = module.edge_logs.aws_s3_bucket_policy.this[0]
}

data "aws_iam_policy_document" "edge_logs" {
  statement {
    sid       = "AWSLogDeliveryWrite"
    actions   = ["s3:PutObject"]
    resources = ["${module.edge_logs.s3_bucket_arn}/cloudfront/*"]

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
    resources = [module.edge_logs.s3_bucket_arn]

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

resource "aws_cloudwatch_log_delivery_destination" "edge_logs" {
  region        = "us-east-1"
  name          = "edge-logs"
  output_format = "parquet"

  delivery_destination_configuration {
    destination_resource_arn = "${module.edge_logs.s3_bucket_arn}/cloudfront"
  }
}

# No cs(Cookie): it carries session cookies. x-edge-request-id is the
# X-Amz-Cf-Id in Caddy's access log, for joining the two.
resource "aws_cloudwatch_log_delivery" "femiwiki_com" {
  depends_on = [module.edge_logs]

  region                   = "us-east-1"
  delivery_source_name     = aws_cloudwatch_log_delivery_source.femiwiki_com.name
  delivery_destination_arn = aws_cloudwatch_log_delivery_destination.edge_logs.arn

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
