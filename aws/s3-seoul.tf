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

resource "aws_s3_bucket" "uploads_seoul" {
  region           = local.seoul_region
  bucket           = "uploads-${data.aws_caller_identity.current.account_id}-${local.seoul_region}-an"
  bucket_namespace = "account-regional"
}

# Extension:AWS puts every object with an ACL, public-read unless the zone
# carries a .htsecure file, and that is not configurable: see
# AmazonS3FileBackend.php's putObject. A bucket created today defaults to
# BucketOwnerEnforced, which refuses an ACL outright with
# AccessControlListNotSupported, so ownership has to accept them.
resource "aws_s3_bucket_ownership_controls" "uploads_seoul" {
  region = local.seoul_region
  bucket = aws_s3_bucket.uploads_seoul.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# block_public_acls has to be off for the same reason: it rejects a PUT that
# carries a public ACL. ignore_public_acls stays on and is load-bearing rather
# than decorative, because the extension asks for public-read on deleted/ too;
# ignoring the ACL leaves the bucket policy as the only thing granting public
# read, and it does not list deleted/ or temp/. The Tokyo deleted bucket keeps
# them private the same way.
resource "aws_s3_bucket_public_access_block" "uploads_seoul" {
  region = local.seoul_region
  bucket = aws_s3_bucket.uploads_seoul.id

  block_public_acls       = false
  ignore_public_acls      = true
  block_public_policy     = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "uploads_seoul" {
  depends_on = [aws_s3_bucket_public_access_block.uploads_seoul]


  region = local.seoul_region
  bucket = aws_s3_bucket.uploads_seoul.bucket
  policy = data.aws_iam_policy_document.uploads_seoul.json
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
      for prefix in local.uploads_public_prefixes : "${aws_s3_bucket.uploads_seoul.arn}/${prefix}"
    ]
  }
}

# The stash is transient and nothing has ever emptied it: the Tokyo temp bucket
# holds 18,504 objects and 5.25 GiB. MediaWiki expires a stash entry in hours,
# so seven days is far past anything it will ask for.
resource "aws_s3_bucket_lifecycle_configuration" "uploads_seoul" {
  region = local.seoul_region
  bucket = aws_s3_bucket.uploads_seoul.id

  rule {
    id     = "expire-the-upload-stash"
    status = "Enabled"

    filter {
      prefix = "temp/"
    }

    expiration {
      days = 7
    }
  }
}

# The dump is taken in Seoul, so it is kept in Seoul. Crossing to Tokyo cost
# $0.0805/GB out, about $26 a year for one dump a night, and bought nothing.
# See femiwiki/infra#892. A bucket cannot change region and its name is global,
# so this is a new bucket under the account-regional namespace rather than a
# move, and femiwiki-backups stays in Tokyo holding everything written before
# today. A restore of something older than this bucket reaches across, which is
# rare enough to pay $0.09/GB for.
resource "aws_s3_bucket" "backups_seoul" {
  region           = local.seoul_region
  bucket           = "backups-${data.aws_caller_identity.current.account_id}-${local.seoul_region}-an"
  bucket_namespace = "account-regional"
}

resource "aws_s3_bucket_lifecycle_configuration" "backups_seoul" {
  region = local.seoul_region
  bucket = aws_s3_bucket.backups_seoul.id

  rule {
    status = "Enabled"
    id     = "Transition mysql dumps to Glacier Deep Archive after 14 days"

    filter {
      prefix = "mysql/"
    }

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

resource "aws_s3_bucket_public_access_block" "backups_seoul" {
  region = local.seoul_region
  bucket = aws_s3_bucket.backups_seoul.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
