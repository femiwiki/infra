resource "aws_budgets_budget" "credit_lapse" {
  name         = "credit-lapse"
  budget_type  = "COST"
  limit_amount = "20"
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  notification {
    comparison_operator = "GREATER_THAN"
    threshold           = 100
    threshold_type      = "PERCENTAGE"
    notification_type   = "ACTUAL"

    subscriber_sns_topic_arns = [aws_sns_topic.cloudwatch_alarms_topic_us.arn]
  }
}

resource "aws_budgets_budget" "lambda" {
  name         = "lambda"
  budget_type  = "COST"
  limit_amount = "1"
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  cost_filter {
    name   = "Service"
    values = ["AWS Lambda", "Amazon EventBridge"]
  }

  cost_types {
    include_credit = false
  }

  dynamic "notification" {
    for_each = toset(["FORECASTED", "ACTUAL"])

    content {
      comparison_operator = "GREATER_THAN"
      threshold           = 0.01
      threshold_type      = "ABSOLUTE_VALUE"
      notification_type   = notification.value

      subscriber_sns_topic_arns = [aws_sns_topic.cloudwatch_alarms_topic_us.arn]
    }
  }
}

resource "aws_budgets_budget" "cloudfront" {
  name         = "cloudfront"
  budget_type  = "COST"
  limit_amount = "40"
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  cost_filter {
    name   = "Service"
    values = ["Amazon CloudFront"]
  }

  cost_types {
    include_credit = false
  }

  notification {
    comparison_operator = "GREATER_THAN"
    threshold           = 100
    threshold_type      = "PERCENTAGE"
    notification_type   = "ACTUAL"

    subscriber_sns_topic_arns = [aws_sns_topic.cloudwatch_alarms_topic_us.arn]
  }
}
