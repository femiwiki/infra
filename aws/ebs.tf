# New volumes, including the root volume of a replaced instance, are encrypted
# with the AWS managed key aws/ebs. Volumes that already exist stay as they are.
resource "aws_ebs_encryption_by_default" "ebs" {
  region  = local.seoul_region
  enabled = true
}
