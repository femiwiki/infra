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
