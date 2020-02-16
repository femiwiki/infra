resource "aws_s3_bucket" "backups" {
  bucket = "femiwiki-backups"

  lifecycle_rule {
    enabled = true
    id      = "Transition mysql dumps to Glacier Deep Archive after 14 days"
    prefix  = "mysql/"

    # NOTE: STANDARD_IA 를 사용할 경우, S3 IA로 가는순간 30일치 요금이 무조건
    # 계산된다는 점을 주의해주세요.

    transition {
      days          = 15
      storage_class = "GLACIER"
    }

    transition {
      days          = 30
      storage_class = "DEEP_ARCHIVE"
    }
  }
}

resource "aws_s3_bucket" "uploaded_files" {
  bucket = "femiwiki-uploaded-files"
}

resource "aws_s3_bucket" "uploaded_files_deleted" {
  bucket = "femiwiki-uploaded-files-deleted"
}

resource "aws_s3_bucket" "uploaded_files_temp" {
  bucket = "femiwiki-uploaded-files-temp"
}

resource "aws_s3_bucket" "uploaded_files_thumb" {
  bucket = "femiwiki-uploaded-files-thumb"
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

    resources = ["${aws_s3_bucket.uploaded_files.arn}/*"]
  }
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

    resources = ["${aws_s3_bucket.uploaded_files_thumb.arn}/*"]
  }
}

