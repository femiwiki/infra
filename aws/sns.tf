# NOTE: AWS SNS topic subscriptions for email cannot be applied with Terraform.
# Please configure it manually.
#
# Reference:
#   https://www.terraform.io/docs/providers/aws/r/sns_topic_subscription.html#email

resource "aws_sns_topic" "cloudwatch_alarms_topic" {
  name   = "CloudWatch_Alarms_Topic"
  policy = data.aws_iam_policy_document.sns_default_policy.json
}

resource "aws_sns_topic" "cloudwatch_alarms_topic_us" {
  name   = "CloudWatch_Alarms_Topic"
  policy = data.aws_iam_policy_document.sns_default_policy.json
  region = "us-east-1"
}

data "aws_iam_policy_document" "sns_default_policy" {
  statement {
    actions = [
      "SNS:GetTopicAttributes",
      "SNS:SetTopicAttributes",
      "SNS:AddPermission",
      "SNS:RemovePermission",
      "SNS:DeleteTopic",
      "SNS:Subscribe",
      "SNS:ListSubscriptionsByTopic",
      "SNS:Publish",
      "SNS:Receive",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"
      values   = ["302617221463"]
    }

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = ["arn:aws:sns:*"]
  }

  statement {
    sid     = "AllowBudgetsPublish"
    actions = ["SNS:Publish"]

    principals {
      type        = "Service"
      identifiers = ["budgets.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = ["302617221463"]
    }

    resources = ["arn:aws:sns:*"]
  }
}

resource "aws_sns_topic" "backup_uploads" {
  name = "backup-uploads"
}

resource "aws_sns_topic_policy" "backup_uploads" {
  arn    = aws_sns_topic.backup_uploads.arn
  policy = data.aws_iam_policy_document.backup_uploads.json
}
