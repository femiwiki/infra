# Caddy's ACME account and certificates, next to the host that reads them

resource "aws_s3_bucket" "caddy_certs" {
  region           = local.seoul_region
  bucket           = "caddy-certs-${data.aws_caller_identity.current.account_id}-${local.seoul_region}-an"
  bucket_namespace = "account-regional"
}

resource "aws_s3_bucket_public_access_block" "caddy_certs" {
  region = local.seoul_region
  bucket = aws_s3_bucket.caddy_certs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "caddy_certs" {
  depends_on = [aws_s3_bucket_public_access_block.caddy_certs]

  region = local.seoul_region
  bucket = aws_s3_bucket.caddy_certs.bucket
  policy = data.aws_iam_policy_document.caddy_certs.json
}

data "aws_iam_policy_document" "caddy_certs" {
  # Prevent all human users downloading the private keys.
  statement {
    effect  = "Deny"
    actions = ["s3:GetObject"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalType"
      values   = ["User"]
    }

    resources = ["${local.caddy_certs}/*"]
  }

  statement {
    sid     = "DenyPlainHttp"
    effect  = "Deny"
    actions = ["s3:*"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      local.caddy_certs,
      "${local.caddy_certs}/*",
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_versioning" "caddy_certs" {
  region = local.seoul_region
  bucket = aws_s3_bucket.caddy_certs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "caddy_certs" {
  region = local.seoul_region
  bucket = aws_s3_bucket.caddy_certs.id

  rule {
    id     = "expire-replaced-certificates"
    status = "Enabled"

    filter {}

    # Every renewal leaves the old certificate as a version; 30 days keeps it
    # to restore if a renewal writes something broken.
    noncurrent_version_expiration {
      noncurrent_days = 30
    }

    expiration {
      expired_object_delete_marker = true
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }
  }
}

#
# Database dumps
#

resource "aws_s3_bucket" "backups" {
  region = local.tokyo_region
  bucket = "femiwiki-backups"
}

resource "aws_s3_bucket_lifecycle_configuration" "backups" {
  region = local.tokyo_region
  bucket = aws_s3_bucket.backups.id

  rule {
    status = "Enabled"
    id     = "Transition mysql dumps to Glacier Deep Archive after 14 days"

    filter {
      prefix = "mysql/"
    }

    # NOTE: When using STANDARD_IA, be aware that a minimum of 30 days of
    # storage charges is always billed the moment an object transitions to S3 IA.

    transition {
      days          = 14
      storage_class = "DEEP_ARCHIVE"
    }
  }

  rule {
    status = "Enabled"
    id     = "Expire replica seeds after 7 days"

    filter {
      prefix = "seed/"
    }

    expiration {
      days = 7
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }
  }
}

resource "aws_s3_bucket_public_access_block" "backups" {
  region = local.tokyo_region
  bucket = aws_s3_bucket.backups.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#
# Terraform state
#

resource "aws_s3_bucket" "tfstate" {
  region           = local.tokyo_region
  bucket           = "tfstate-${data.aws_caller_identity.current.account_id}-${local.tokyo_region}-an"
  bucket_namespace = "account-regional"
}

resource "aws_s3_bucket_public_access_block" "tfstate" {
  region = local.tokyo_region
  bucket = aws_s3_bucket.tfstate.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "tfstate" {
  region = local.tokyo_region
  bucket = aws_s3_bucket.tfstate.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  region = local.tokyo_region
  bucket = aws_s3_bucket.tfstate.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "tfstate" {
  region = local.tokyo_region
  bucket = aws_s3_bucket.tfstate.id

  dynamic "rule" {
    for_each = ["grafana"]

    content {
      status = "Enabled"
      id     = "Expire the ${rule.value} state lock's old versions"

      filter {
        prefix = "${rule.value}/terraform.tfstate.tflock"
      }

      noncurrent_version_expiration {
        noncurrent_days = 1
      }

      expiration {
        expired_object_delete_marker = true
      }
    }
  }
}

resource "aws_s3_bucket" "cost_exports" {
  region           = local.tokyo_region
  bucket           = "cost-exports-${data.aws_caller_identity.current.account_id}-${local.tokyo_region}-an"
  bucket_namespace = "account-regional"
}

resource "aws_s3_bucket_public_access_block" "cost_exports" {
  region = local.tokyo_region
  bucket = aws_s3_bucket.cost_exports.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Both the Tokyo bucket and the Seoul one that replaces it (femiwiki/femiwiki#667)
data "aws_iam_policy_document" "cost_exports_bucket" {
  for_each = {
    cost_exports   = aws_s3_bucket.cost_exports.arn
    cost_and_usage = aws_s3_bucket.cost_and_usage.arn
  }

  statement {
    actions   = ["s3:GetBucketPolicy", "s3:PutObject"]
    resources = [each.value, "${each.value}/*"]

    principals {
      type        = "Service"
      identifiers = ["bcm-data-exports.amazonaws.com", "billingreports.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }

    condition {
      test     = "StringLike"
      variable = "aws:SourceArn"
      values = [
        "arn:aws:cur:us-east-1:${data.aws_caller_identity.current.account_id}:definition/*",
        "arn:aws:bcm-data-exports:us-east-1:${data.aws_caller_identity.current.account_id}:export/*",
      ]
    }
  }

  statement {
    sid     = "DenyPlainHttp"
    effect  = "Deny"
    actions = ["s3:*"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [each.value, "${each.value}/*"]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "cost_exports" {
  region = local.tokyo_region
  bucket = aws_s3_bucket.cost_exports.id
  policy = data.aws_iam_policy_document.cost_exports_bucket["cost_exports"].json
}

# The Data Export's monthly line items, read by femiwiki.github.io's collect job

resource "aws_s3_bucket" "cost_and_usage" {
  region           = local.seoul_region
  bucket           = "cost-exports-${data.aws_caller_identity.current.account_id}-${local.seoul_region}-an"
  bucket_namespace = "account-regional"
}

resource "aws_s3_bucket_public_access_block" "cost_and_usage" {
  region = local.seoul_region
  bucket = aws_s3_bucket.cost_and_usage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "cost_and_usage" {
  depends_on = [aws_s3_bucket_public_access_block.cost_and_usage]

  region = local.seoul_region
  bucket = aws_s3_bucket.cost_and_usage.id
  policy = data.aws_iam_policy_document.cost_exports_bucket["cost_and_usage"].json
}

# No expiration: the collect job re-reads every month the export has written.
resource "aws_s3_bucket_lifecycle_configuration" "cost_and_usage" {
  region = local.seoul_region
  bucket = aws_s3_bucket.cost_and_usage.id

  rule {
    id     = "abort-incomplete-uploads"
    status = "Enabled"

    filter {}

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

resource "aws_s3_bucket" "rate_limit" {
  region           = local.seoul_region
  bucket           = "rate-limit-${data.aws_caller_identity.current.account_id}-${local.seoul_region}-an"
  bucket_namespace = "account-regional"
}

resource "aws_s3_bucket_public_access_block" "rate_limit" {
  region = local.seoul_region
  bucket = aws_s3_bucket.rate_limit.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "rate_limit" {
  region = local.seoul_region
  bucket = aws_s3_bucket.rate_limit.id

  rule {
    id     = "expire-states-of-gone-containers"
    status = "Enabled"

    filter {}

    expiration {
      days = 1
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }
  }
}

resource "aws_s3_bucket_policy" "rate_limit" {
  depends_on = [aws_s3_bucket_public_access_block.rate_limit]

  region = local.seoul_region
  bucket = aws_s3_bucket.rate_limit.bucket
  policy = data.aws_iam_policy_document.rate_limit.json
}

data "aws_iam_policy_document" "rate_limit" {
  statement {
    sid     = "DenyPlainHttp"
    effect  = "Deny"
    actions = ["s3:*"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      aws_s3_bucket.rate_limit.arn,
      "${aws_s3_bucket.rate_limit.arn}/*",
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}
