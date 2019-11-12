resource "aws_cloudwatch_metric_alarm" "mediawiki_cpu_credit_balance_cloud_watch_alarm" {
  alarm_name  = "Mediawiki CPU credit balance cloud watch alarm"
  metric_name = "CPUCreditBalance"
  namespace   = "AWS/EC2"
  period      = 300
  statistic   = "Minimum"
  dimensions = {
    InstanceId = aws_instance.mediawiki.id
  }
  evaluation_periods  = "1"
  threshold           = "216"
  comparison_operator = "LessThanThreshold"
  datapoints_to_alarm = 1
  alarm_actions       = [aws_sns_topic.cloudwatch_alarms_topic.arn]
}

resource "aws_cloudwatch_metric_alarm" "database_cpu_credit_balance_cloud_watch_alarm" {
  alarm_name  = "Database CPU credit balance cloud watch alarm"
  metric_name = "CPUCreditBalance"
  namespace   = "AWS/EC2"
  period      = 300
  statistic   = "Minimum"
  dimensions = {
    InstanceId = aws_instance.database_bots.id
  }
  evaluation_periods  = "1"
  threshold           = "108"
  comparison_operator = "LessThanThreshold"
  datapoints_to_alarm = 1
  alarm_actions       = [aws_sns_topic.cloudwatch_alarms_topic.arn]
}

resource "aws_cloudwatch_metric_alarm" "database_burst_balance_cloud_watch_alarm" {
  alarm_name  = "Database Burst Balance cloud watch alarm"
  metric_name = "BurstBalance"
  namespace   = "AWS/EBS"
  period      = 300
  statistic   = "Minimum"
  dimensions = {
    VolumeId = aws_instance.database_bots.root_block_device.0.volume_id
  }
  evaluation_periods  = "1"
  threshold           = "75"
  comparison_operator = "LessThanThreshold"
  datapoints_to_alarm = 1
  alarm_actions       = [aws_sns_topic.cloudwatch_alarms_topic.arn]
}
