# Caddy's ACME account and certificates, next to the host that reads them

module "caddy_certs" {
  source                                = "terraform-aws-modules/s3-bucket/aws"
  version                               = "5.17.0"
  region                                = local.seoul_region
  bucket                                = "caddy-certs-${data.aws_caller_identity.current.account_id}-${local.seoul_region}-an"
  bucket_namespace                      = "account-regional"
  attach_deny_insecure_transport_policy = true
  attach_policy                         = true
  policy                                = data.aws_iam_policy_document.caddy_certs.json
  versioning                            = { enabled = true }
  lifecycle_rule = [
    {
      id      = "expire-replaced-certificates"
      enabled = true
      # Every renewal leaves the old certificate as a version; 30 days keeps it
      # to restore if a renewal writes something broken.
      noncurrent_version_expiration          = { days = 30 }
      expiration                             = { expired_object_delete_marker = true }
      abort_incomplete_multipart_upload_days = 1
    },
  ]
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

# Roles grant both buckets until every backend reads state (femiwiki/femiwiki#666).
locals {
  tfstate_buckets = [aws_s3_bucket.tfstate.arn, module.state.s3_bucket_arn]
}

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

module "state" {
  source                                = "terraform-aws-modules/s3-bucket/aws"
  version                               = "5.17.0"
  region                                = local.seoul_region
  bucket                                = "tfstate-${data.aws_caller_identity.current.account_id}-${local.seoul_region}-an"
  bucket_namespace                      = "account-regional"
  attach_deny_insecure_transport_policy = true
  versioning                            = { enabled = true }
  server_side_encryption_configuration = {
    rule = { apply_server_side_encryption_by_default = { sse_algorithm = "AES256" } }
  }
  lifecycle_rule = [
    for workspace in ["grafana"] : {
      id                            = "Expire the ${workspace} state lock's old versions"
      enabled                       = true
      filter                        = { prefix = "${workspace}/terraform.tfstate.tflock" }
      noncurrent_version_expiration = { days = 1 }
      expiration                    = { expired_object_delete_marker = true }
    }
  ]
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
    cost_and_usage = module.cost_and_usage.s3_bucket_arn
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

module "rate_limit" {
  source                                = "terraform-aws-modules/s3-bucket/aws"
  version                               = "5.17.0"
  region                                = local.seoul_region
  bucket                                = "rate-limit-${data.aws_caller_identity.current.account_id}-${local.seoul_region}-an"
  bucket_namespace                      = "account-regional"
  attach_deny_insecure_transport_policy = true
  lifecycle_rule = [
    {
      id                                     = "expire-states-of-gone-containers"
      enabled                                = true
      expiration                             = { days = 1 }
      abort_incomplete_multipart_upload_days = 1
    },
  ]
}

moved {
  from = aws_s3_bucket.rate_limit
  to   = module.rate_limit.aws_s3_bucket.this[0]
}

moved {
  from = aws_s3_bucket_public_access_block.rate_limit
  to   = module.rate_limit.aws_s3_bucket_public_access_block.this[0]
}

moved {
  from = aws_s3_bucket_lifecycle_configuration.rate_limit
  to   = module.rate_limit.aws_s3_bucket_lifecycle_configuration.this[0]
}

moved {
  from = aws_s3_bucket_policy.rate_limit
  to   = module.rate_limit.aws_s3_bucket_policy.this[0]
}

# The Data Export's monthly line items, read by femiwiki.github.io's collect job
module "cost_and_usage" {
  source           = "terraform-aws-modules/s3-bucket/aws"
  version          = "5.17.0"
  region           = local.seoul_region
  bucket           = "cost-exports-${data.aws_caller_identity.current.account_id}-${local.seoul_region}-an"
  bucket_namespace = "account-regional"
  attach_policy    = true
  policy           = data.aws_iam_policy_document.cost_exports_bucket["cost_and_usage"].json
  lifecycle_rule = [
    {
      id                                     = "abort-incomplete-uploads"
      enabled                                = true
      abort_incomplete_multipart_upload_days = 7
    },
  ]
}

moved {
  from = aws_s3_bucket.cost_and_usage
  to   = module.cost_and_usage.aws_s3_bucket.this[0]
}

moved {
  from = aws_s3_bucket_public_access_block.cost_and_usage
  to   = module.cost_and_usage.aws_s3_bucket_public_access_block.this[0]
}

moved {
  from = aws_s3_bucket_policy.cost_and_usage
  to   = module.cost_and_usage.aws_s3_bucket_policy.this[0]
}

moved {
  from = aws_s3_bucket_lifecycle_configuration.cost_and_usage
  to   = module.cost_and_usage.aws_s3_bucket_lifecycle_configuration.this[0]
}

locals {
  # Public: hash dirs (one hex char), archive/ and the thumb zone. Anything
  # unlisted, such as deleted/ and temp/, stays private.
  uploads_public_prefixes = concat(
    [for c in ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f"] : "${c}/*"],
    ["archive/*", "thumb/*"],
  )
}

module "uploads_seoul" {
  source           = "terraform-aws-modules/s3-bucket/aws"
  version          = "5.17.0"
  region           = local.seoul_region
  bucket           = "uploads-${data.aws_caller_identity.current.account_id}-${local.seoul_region}-an"
  bucket_namespace = "account-regional"

  # Extension:AWS puts every object with an ACL (AmazonS3FileBackend.php's putObject),
  # which the BucketOwnerEnforced default refuses, so ownership has to accept them.
  control_object_ownership = true
  object_ownership         = "BucketOwnerPreferred"

  # A public-read ACL comes even on deleted/, so ignore_public_acls leaves the
  # policy, which lists neither deleted/ nor temp/, as the only public grant.
  block_public_acls       = false
  ignore_public_acls      = true
  block_public_policy     = false
  restrict_public_buckets = false

  attach_policy = true
  policy        = data.aws_iam_policy_document.uploads_seoul.json

  # MediaWiki expires a stash entry in hours, and nothing else empties temp/:
  # the Tokyo temp bucket holds 18,504 objects and 5.25 GiB.
  lifecycle_rule = [
    {
      id         = "expire-the-upload-stash"
      enabled    = true
      filter     = { prefix = "temp/" }
      expiration = { days = 7 }
    },
    {
      id                                     = "abort-incomplete-multipart-uploads"
      enabled                                = true
      abort_incomplete_multipart_upload_days = 7
    },
  ]
}

data "aws_iam_policy_document" "uploads_seoul" {
  statement {
    sid     = "PublicReadOfThePublicZones"
    actions = ["s3:GetObject"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      for prefix in local.uploads_public_prefixes : "${module.uploads_seoul.s3_bucket_arn}/${prefix}"
    ]
  }
}

# Kept where the dump is taken; femiwiki-backups in Tokyo holds the older ones (femiwiki/infra#892)
module "backups_seoul" {
  source           = "terraform-aws-modules/s3-bucket/aws"
  version          = "5.17.0"
  region           = local.seoul_region
  bucket           = "backups-${data.aws_caller_identity.current.account_id}-${local.seoul_region}-an"
  bucket_namespace = "account-regional"
  lifecycle_rule = [
    {
      id         = "Transition mysql dumps to Glacier Deep Archive after 14 days"
      enabled    = true
      filter     = { prefix = "mysql/" }
      transition = [{ days = 14, storage_class = "DEEP_ARCHIVE" }]
    },
    {
      id                                     = "Expire replica seeds after 7 days"
      enabled                                = true
      filter                                 = { prefix = "seed/" }
      expiration                             = { days = 7 }
      abort_incomplete_multipart_upload_days = 1
    },
  ]
  attach_deny_insecure_transport_policy = true
}

