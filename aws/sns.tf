resource "aws_sns_topic" "cloudwatch_alarms_topic_us" {
  name   = "CloudWatch_Alarms_Topic"
  policy = data.aws_iam_policy_document.sns_default_policy.json
  region = "us-east-1"
}

# Seoul alarms. It also mails, so a failing sns-discord still reaches someone.
resource "aws_sns_topic" "cloudwatch_alarms" {
  name   = "cloudwatch-alarms"
  policy = data.aws_iam_policy_document.sns_default_policy.json
}

# Stays pending until the link in the confirmation mail is clicked. Terraform
# cannot delete a pending subscription; AWS drops it after three days.
resource "aws_sns_topic_subscription" "cloudwatch_alarms_email" {
  topic_arn = aws_sns_topic.cloudwatch_alarms.arn
  protocol  = "email"
  endpoint  = "admin@femiwiki.com"
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
