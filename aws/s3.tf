resource "aws_s3_bucket" "uploaded_files" {
  bucket = "femiwiki-uploaded-files"
}

resource "aws_s3_bucket_policy" "uploaded_files" {
  bucket = aws_s3_bucket.uploaded_files.bucket

  policy = data.aws_iam_policy_document.uploaded_files.json
}

data "aws_iam_policy_document" "uploaded_files" {
  statement {
    actions = ["s3:GetObject"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = ["${local.uploaded_files}/*"]
  }
}

resource "aws_s3_bucket" "uploaded_files_deleted" {
  bucket = "femiwiki-uploaded-files-deleted"
}

resource "aws_s3_bucket_public_access_block" "uploaded_files_deleted" {
  bucket = aws_s3_bucket.uploaded_files_deleted.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "uploaded_files_temp" {
  bucket = "femiwiki-uploaded-files-temp"
}

resource "aws_s3_bucket_public_access_block" "uploaded_files_temp" {
  bucket = aws_s3_bucket.uploaded_files_temp.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "uploaded_files_thumb" {
  bucket = "femiwiki-uploaded-files-thumb"
}

resource "aws_s3_bucket_policy" "uploaded_files_thumb" {
  bucket = aws_s3_bucket.uploaded_files_thumb.bucket

  policy = data.aws_iam_policy_document.uploaded_files_thumb.json
}

data "aws_iam_policy_document" "uploaded_files_thumb" {
  statement {
    actions = ["s3:GetObject"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = ["${local.uploaded_files_thumb}/*"]
  }
}

resource "aws_s3_bucket" "backups" {
  bucket = "femiwiki-backups"

  lifecycle_rule {
    enabled = true
    id      = "Transition mysql dumps to Glacier Deep Archive after 14 days"
    prefix  = "mysql/"

    # NOTE: STANDARD_IA 를 사용할 경우, S3 IA로 가는순간 30일치 요금이 무조건
    # 계산된다는 점을 주의해주세요.

    transition {
      days          = 14
      storage_class = "DEEP_ARCHIVE"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "backups" {
  bucket = aws_s3_bucket.backups.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
