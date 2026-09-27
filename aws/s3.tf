resource "aws_s3_bucket" "digger" {
  region = local.tokyo_region
  bucket = "femiwiki-digger-state"
}

resource "aws_s3_bucket_public_access_block" "digger" {
  region = local.tokyo_region
  bucket = aws_s3_bucket.digger.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#
# Secrets for MediaWiki run
#

resource "aws_s3_bucket" "secrets" {
  region = local.tokyo_region
  bucket = "femiwiki-secrets"
}

resource "aws_s3_bucket_public_access_block" "secrets" {
  region = local.tokyo_region
  bucket = aws_s3_bucket.secrets.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "secrets" {
  region = local.tokyo_region
  bucket = aws_s3_bucket.secrets.bucket

  policy = data.aws_iam_policy_document.s3_secrets.json
}

data "aws_iam_policy_document" "s3_secrets" {
  # Prevent all human users downloading secret from S3.
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

    resources = ["${local.secrets}/*"]
  }
}

resource "aws_s3_bucket_versioning" "secrets" {
  region = local.tokyo_region
  bucket = aws_s3_bucket.secrets.id
  versioning_configuration {
    status = "Enabled"
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

data "aws_iam_policy_document" "cost_exports_bucket" {
  statement {
    actions   = ["s3:GetBucketPolicy", "s3:PutObject"]
    resources = [aws_s3_bucket.cost_exports.arn, "${aws_s3_bucket.cost_exports.arn}/*"]

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
}

resource "aws_s3_bucket_policy" "cost_exports" {
  region = local.tokyo_region
  bucket = aws_s3_bucket.cost_exports.id
  policy = data.aws_iam_policy_document.cost_exports_bucket.json
}
