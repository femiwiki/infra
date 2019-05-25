resource "aws_s3_bucket_policy" "femiwiki-uploaded-files" {
  bucket = "femiwiki-uploaded-files"

  policy = <<POLICY
{
  "Id": "...",
  "Statement": [
    {
      "Action": "s3:GetObject",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Resource": "arn:aws:s3:::femiwiki-uploaded-files/*",
      "Sid": "..."
    }
  ],
  "Version": "2008-10-17"
}
POLICY
}

resource "aws_s3_bucket_policy" "femiwiki-uploaded-files-thumb" {
  bucket = "femiwiki-uploaded-files-thumb"

  policy = <<POLICY
{
  "Id": "...",
  "Statement": [
    {
      "Action": "s3:GetObject",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Resource": "arn:aws:s3:::femiwiki-uploaded-files-thumb/*",
      "Sid": "..."
    }
  ],
  "Version": "2008-10-17"
}
POLICY
}
