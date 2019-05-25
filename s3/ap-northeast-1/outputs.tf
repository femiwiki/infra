output "aws_s3_bucket_femiwiki-backups_id" {
  value = "${aws_s3_bucket.femiwiki-backups.id}"
}

output "aws_s3_bucket_femiwiki-uploaded-files-deleted_id" {
  value = "${aws_s3_bucket.femiwiki-uploaded-files-deleted.id}"
}

output "aws_s3_bucket_femiwiki-uploaded-files-temp_id" {
  value = "${aws_s3_bucket.femiwiki-uploaded-files-temp.id}"
}

output "aws_s3_bucket_femiwiki-uploaded-files-thumb_id" {
  value = "${aws_s3_bucket.femiwiki-uploaded-files-thumb.id}"
}

output "aws_s3_bucket_femiwiki-uploaded-files_id" {
  value = "${aws_s3_bucket.femiwiki-uploaded-files.id}"
}

output "aws_s3_bucket_policy_femiwiki-uploaded-files-thumb_id" {
  value = "${aws_s3_bucket_policy.femiwiki-uploaded-files-thumb.id}"
}

output "aws_s3_bucket_policy_femiwiki-uploaded-files_id" {
  value = "${aws_s3_bucket_policy.femiwiki-uploaded-files.id}"
}
