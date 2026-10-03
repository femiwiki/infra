resource "aws_cloudwatch_metric_alarm" "bounce_rate" {
  alarm_name          = "Bounce Rate"
  namespace           = "AWS/SES"
  metric_name         = "Reputation.BounceRate"
  period              = 300
  statistic           = "Average"
  threshold           = 0.05
  comparison_operator = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm = 1
  evaluation_periods  = 1
  alarm_actions       = [aws_sns_topic.cloudwatch_alarms_topic_us.arn]
  treat_missing_data  = "ignore"
  region              = "us-east-1"
}

resource "aws_cloudwatch_metric_alarm" "complaint_rate" {
  alarm_name          = "Complaint Rate"
  namespace           = "AWS/SES"
  metric_name         = "Reputation.ComplaintRate"
  period              = 300
  statistic           = "Average"
  threshold           = 0.001
  comparison_operator = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm = 1
  evaluation_periods  = 1
  alarm_actions       = [aws_sns_topic.cloudwatch_alarms_topic_us.arn]
  treat_missing_data  = "ignore"
  region              = "us-east-1"
}

resource "aws_cloudwatch_metric_alarm" "femiwiki_pages" {
  for_each = aws_route53_health_check.femiwiki_pages

  alarm_name  = "${each.key} awsroute53 Low-HealthCheckStatus"
  namespace   = "AWS/Route53"
  metric_name = "HealthCheckStatus"
  period      = 60
  statistic   = "Minimum"
  dimensions = {
    HealthCheckId = each.value.id
  }
  threshold           = 1
  comparison_operator = "LessThanThreshold"
  datapoints_to_alarm = 5
  evaluation_periods  = 5
  alarm_actions       = [aws_sns_topic.cloudwatch_alarms_topic_us.arn]
  ok_actions          = [aws_sns_topic.cloudwatch_alarms_topic_us.arn]
  region              = "us-east-1"
}


resource "aws_cloudwatch_metric_alarm" "cloudfront_requests" {
  alarm_name  = "CloudFront Requests"
  namespace   = "AWS/CloudFront"
  metric_name = "Requests"
  period      = 300
  statistic   = "Sum"
  dimensions = {
    DistributionId = aws_cloudfront_distribution.femiwiki_com.id
    Region         = "Global"
  }
  threshold           = 60000
  comparison_operator = "GreaterThanThreshold"
  datapoints_to_alarm = 3
  evaluation_periods  = 3
  alarm_actions       = [aws_sns_topic.cloudwatch_alarms_topic_us.arn]
  ok_actions          = [aws_sns_topic.cloudwatch_alarms_topic_us.arn]
  treat_missing_data  = "notBreaching"
  region              = "us-east-1"
}
