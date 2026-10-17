# The one trail: Event history stops at 90 days, and the first copy of management
# events is free while a second trail's costs $2 per 100,000 (#1275).
locals {
  trail_name = "management-events"
}

resource "aws_cloudtrail" "management_events" {
  depends_on = [module.trail]

  region                        = local.seoul_region
  name                          = local.trail_name
  s3_bucket_name                = module.trail.s3_bucket_id
  is_multi_region_trail         = true
  include_global_service_events = true
  enable_log_file_validation    = true
}

module "trail" {
  source                                = "terraform-aws-modules/s3-bucket/aws"
  version                               = "5.17.0"
  region                                = local.seoul_region
  bucket                                = "trail-${data.aws_caller_identity.current.account_id}-${local.seoul_region}-an"
  bucket_namespace                      = "account-regional"
  attach_deny_insecure_transport_policy = true
  attach_policy                         = true
  policy                                = data.aws_iam_policy_document.trail.json
  # Expiry only: the log files are a few KB, and a transition costs more than it
  # saves.
  lifecycle_rule = [
    {
      id                                     = "expire-after-a-year"
      enabled                                = true
      expiration                             = { days = 365 }
      abort_incomplete_multipart_upload_days = 1
    },
  ]
}

data "aws_iam_policy_document" "trail" {
  statement {
    sid       = "AWSCloudTrailAclCheck"
    actions   = ["s3:GetBucketAcl"]
    resources = [module.trail.s3_bucket_arn]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["arn:aws:cloudtrail:${local.seoul_region}:${data.aws_caller_identity.current.account_id}:trail/${local.trail_name}"]
    }
  }

  statement {
    sid       = "AWSCloudTrailWrite"
    actions   = ["s3:PutObject"]
    resources = ["${module.trail.s3_bucket_arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["arn:aws:cloudtrail:${local.seoul_region}:${data.aws_caller_identity.current.account_id}:trail/${local.trail_name}"]
    }
  }
}
