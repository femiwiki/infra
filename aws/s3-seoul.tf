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
