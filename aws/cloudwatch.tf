resource "aws_cloudwatch_log_group" "discord_noti" {
  name = "/aws/lambda/DiscordNoti"
}

resource "aws_cloudwatch_log_group" "discord_noti_us" {
  name   = "/aws/lambda/DiscordNoti"
  region = "us-east-1"
}

resource "aws_cloudwatch_metric_alarm" "femiwiki_volume_idle_time_cloud_watch_alarm" {
  alarm_name  = "Femiwiki VolumeIdleTime"
  namespace   = "AWS/EBS"
  metric_name = "VolumeIdleTime"
  period      = 300
  statistic   = "Minimum"
  dimensions = {
    VolumeId = aws_instance.docker.root_block_device[0].volume_id
  }
  threshold           = 20
  comparison_operator = "LessThanThreshold"
  datapoints_to_alarm = 2
  evaluation_periods  = 2
  alarm_actions       = []
}

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

resource "aws_cloudwatch_metric_alarm" "backup_missing" {
  alarm_name  = "Backup missing"
  namespace   = "AWS/SNS"
  metric_name = "NumberOfMessagesPublished"
  period      = 3600
  statistic   = "Sum"
  dimensions = {
    TopicName = aws_sns_topic.backup_uploads.name
  }
  threshold           = 1
  comparison_operator = "LessThanThreshold"
  datapoints_to_alarm = 24
  evaluation_periods  = 24
  treat_missing_data  = "breaching"
  alarm_actions       = [aws_sns_topic.cloudwatch_alarms_topic.arn]
  ok_actions          = [aws_sns_topic.cloudwatch_alarms_topic.arn]
}
