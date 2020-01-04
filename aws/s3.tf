resource "aws_s3_bucket" "backups" {
  bucket = "femiwiki-backups"

  lifecycle_rule {
    enabled = true
    id      = "Transition mysql dumps to Glacier Deep Archive after 14 days"
    prefix  = "mysql/"

    transition {
      days          = 14
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

resource "aws_s3_bucket" "uploaded_files_validate" {
  bucket = "femiwiki-uploaded-files-validate"
}

resource "aws_s3_bucket" "miri-files" {
  bucket = "miri-temporary-bucket"
  acl = "private"

  versioning {
    enabled = false
  }
}
