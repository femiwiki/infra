locals {
  # The public zone sits at the bucket root with two hash levels, so its top
  # level is one hex character, plus archive/ for a file's older versions. The
  # thumb zone has its own path. Everything not listed here stays private,
  # which is how deleted/ and temp/ are kept out without a Deny statement that
  # would also have to carve out our own principals.
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
  ]
}

moved {
  from = aws_s3_bucket.uploads_seoul
  to   = module.uploads_seoul.aws_s3_bucket.this[0]
}

moved {
  from = aws_s3_bucket_ownership_controls.uploads_seoul
  to   = module.uploads_seoul.aws_s3_bucket_ownership_controls.this[0]
}

moved {
  from = aws_s3_bucket_public_access_block.uploads_seoul
  to   = module.uploads_seoul.aws_s3_bucket_public_access_block.this[0]
}

moved {
  from = aws_s3_bucket_policy.uploads_seoul
  to   = module.uploads_seoul.aws_s3_bucket_policy.this[0]
}

moved {
  from = aws_s3_bucket_lifecycle_configuration.uploads_seoul
  to   = module.uploads_seoul.aws_s3_bucket_lifecycle_configuration.this[0]
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

moved {
  from = aws_s3_bucket.backups_seoul
  to   = module.backups_seoul.aws_s3_bucket.this[0]
}

moved {
  from = aws_s3_bucket_lifecycle_configuration.backups_seoul
  to   = module.backups_seoul.aws_s3_bucket_lifecycle_configuration.this[0]
}

moved {
  from = aws_s3_bucket_public_access_block.backups_seoul
  to   = module.backups_seoul.aws_s3_bucket_public_access_block.this[0]
}
