# NOTE: email에 대한 AWS SNS topic subscription은 테라폼으로 적용할 수 없습니다.
# 수동으로 설정해 주세요.
#
# Reference:
#   https://www.terraform.io/docs/providers/aws/r/sns_topic_subscription.html#email

resource "aws_sns_topic" "cloudwatch_alarms_topic" {
  name   = "CloudWatch_Alarms_Topic"
  policy = data.aws_iam_policy_document.sns_default_policy.json
}

resource "aws_sns_topic" "cloudwatch_alarms_topic_us" {
  provider = aws.us
  name     = "CloudWatch_Alarms_Topic"
  policy   = data.aws_iam_policy_document.sns_default_policy.json
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
}
