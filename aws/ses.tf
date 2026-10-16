resource "aws_ses_domain_identity" "femiwiki_com" {
  domain = "femiwiki.com"
  region = "us-east-1"
}

resource "aws_ses_domain_dkim" "femiwiki_com" {
  domain = aws_ses_domain_identity.femiwiki_com.domain
  region = "us-east-1"
}

# ref femiwiki/femiwiki#365 ("AWS SES Return-Path domain configuration")
resource "aws_ses_domain_mail_from" "femiwiki_com" {
  domain           = aws_ses_domain_identity.femiwiki_com.domain
  mail_from_domain = "bounce.${aws_ses_domain_identity.femiwiki_com.domain}"
  region           = "us-east-1"
}

# SES publishes a notification only to a topic in its own region.
resource "aws_sns_topic" "ses_bounces" {
  name   = "SES_Bounces"
  policy = data.aws_iam_policy_document.ses_bounces.json
  region = "us-east-1"
}

data "aws_iam_policy_document" "ses_bounces" {
  statement {
    sid     = "AllowSesPublish"
    actions = ["SNS:Publish"]

    principals {
      type        = "Service"
      identifiers = ["ses.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }

    resources = ["arn:aws:sns:us-east-1:${data.aws_caller_identity.current.account_id}:SES_Bounces"]
  }
}

resource "aws_ses_identity_notification_topic" "bounce" {
  for_each = {
    domain = aws_ses_domain_identity.femiwiki_com.domain
  }

  region            = "us-east-1"
  identity          = each.value
  notification_type = "Bounce"
  topic_arn         = aws_sns_topic.ses_bounces.arn
}

# SES keeps mailing feedback unless both bounces and complaints have a topic.
# bounce-handler logs complaints as skipped; the Complaint Rate alarm watches them.
resource "aws_ses_identity_notification_topic" "complaint" {
  region            = "us-east-1"
  identity          = aws_ses_domain_identity.femiwiki_com.domain
  notification_type = "Complaint"
  topic_arn         = aws_sns_topic.ses_bounces.arn
}

resource "aws_sesv2_email_identity_feedback_attributes" "femiwiki_com" {
  region                   = "us-east-1"
  email_identity           = aws_ses_domain_identity.femiwiki_com.domain
  email_forwarding_enabled = false

  depends_on = [
    aws_ses_identity_notification_topic.bounce,
    aws_ses_identity_notification_topic.complaint,
  ]
}
