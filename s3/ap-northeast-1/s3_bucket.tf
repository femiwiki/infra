resource "aws_s3_bucket" "femiwiki-backups" {
  acl            = "private"
  arn            = "arn:aws:s3:::femiwiki-backups"
  bucket         = "femiwiki-backups"
  force_destroy  = false
  hosted_zone_id = "Z2M4EHUR26P7ZW"

  lifecycle_rule {
    abort_incomplete_multipart_upload_days = "0"
    enabled                                = true
    id                                     = "Transition mysql dumps to Glacier Deep Archive after 14 days"
    prefix                                 = "mysql/"
    tags                                   {}

    transition {
      days          = "14"
      storage_class = "DEEP_ARCHIVE"
    }
  }

  region        = "ap-northeast-1"
  request_payer = "BucketOwner"
  tags          {}

  versioning {
    enabled    = false
    mfa_delete = false
  }
}

resource "aws_s3_bucket" "femiwiki-uploaded-files" {
  acl            = "private"
  arn            = "arn:aws:s3:::femiwiki-uploaded-files"
  bucket         = "femiwiki-uploaded-files"
  force_destroy  = false
  hosted_zone_id = "Z2M4EHUR26P7ZW"
  region         = "ap-northeast-1"
  request_payer  = "BucketOwner"
  tags           {}

  versioning {
    enabled    = false
    mfa_delete = false
  }
}

resource "aws_s3_bucket" "femiwiki-uploaded-files-deleted" {
  acl            = "private"
  arn            = "arn:aws:s3:::femiwiki-uploaded-files-deleted"
  bucket         = "femiwiki-uploaded-files-deleted"
  force_destroy  = false
  hosted_zone_id = "Z2M4EHUR26P7ZW"
  region         = "ap-northeast-1"
  request_payer  = "BucketOwner"
  tags           {}

  versioning {
    enabled    = false
    mfa_delete = false
  }
}

resource "aws_s3_bucket" "femiwiki-uploaded-files-temp" {
  acl            = "private"
  arn            = "arn:aws:s3:::femiwiki-uploaded-files-temp"
  bucket         = "femiwiki-uploaded-files-temp"
  force_destroy  = false
  hosted_zone_id = "Z2M4EHUR26P7ZW"
  region         = "ap-northeast-1"
  request_payer  = "BucketOwner"
  tags           {}

  versioning {
    enabled    = false
    mfa_delete = false
  }
}

resource "aws_s3_bucket" "femiwiki-uploaded-files-thumb" {
  acl            = "private"
  arn            = "arn:aws:s3:::femiwiki-uploaded-files-thumb"
  bucket         = "femiwiki-uploaded-files-thumb"
  force_destroy  = false
  hosted_zone_id = "Z2M4EHUR26P7ZW"
  region         = "ap-northeast-1"
  request_payer  = "BucketOwner"
  tags           {}

  versioning {
    enabled    = false
    mfa_delete = false
  }
}
