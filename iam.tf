resource "aws_iam_role" "amazon_s3_access" {
  name        = "AmazonS3Access"
  description = "Allows EC2 instances to call AWS services on your behalf."
  path        = "/"

  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "amazon_s3_access" {
  name        = "AmazonS3Access"
  description = "Provide Access to Amazon S3 buckets."

  policy = data.aws_iam_policy_document.amazon_s3_access.json
}

data "aws_iam_policy_document" "amazon_s3_access" {
  statement {
    actions = ["s3:*"]
    resources = [
      "arn:aws:s3:::femiwiki-uploaded-files/*",
      "arn:aws:s3:::femiwiki-uploaded-files-thumb/*",
      "arn:aws:s3:::femiwiki-uploaded-files-temp/*",
      "arn:aws:s3:::femiwiki-uploaded-files-deleted/*"
    ]
  }

  statement {
    actions = [
      "s3:Get*",
      "s3:List*"
    ]
    resources = [
      "arn:aws:s3:::femiwiki-uploaded-files",
      "arn:aws:s3:::femiwiki-uploaded-files-thumb",
      "arn:aws:s3:::femiwiki-uploaded-files-temp",
      "arn:aws:s3:::femiwiki-uploaded-files-deleted"
    ]
  }
}

resource "aws_iam_role" "upload_backup" {
  name        = "UploadBackup"
  description = "Allows EC2 instances to upload to the backup bucket."
  path        = "/"

  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "upload_backup" {
  statement {
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::femiwiki-backups/mysql/*"]
  }
}
