resource "aws_cloudwatch_metric_alarm" "femiwiki_cpu_credit_balance_cloud_watch_alarm" {
  alarm_name  = "Femiwiki CPU credit balance cloud watch alarm"
  metric_name = "CPUCreditBalance"
  namespace   = "AWS/EC2"
  period      = 300
  statistic   = "Minimum"
  dimensions = {
    InstanceId = aws_instance.femiwiki.id
  }
  evaluation_periods  = "1"
  threshold           = "108"
  comparison_operator = "LessThanThreshold"
  datapoints_to_alarm = 1
  alarm_actions       = [aws_sns_topic.cloudwatch_alarms_topic.arn]
}

resource "aws_cloudwatch_metric_alarm" "femiwiki_burst_balance_cloud_watch_alarm" {
  alarm_name  = "Femiwiki Burst Balance cloud watch alarm"
  metric_name = "BurstBalance"
  namespace   = "AWS/EBS"
  period      = 300
  statistic   = "Minimum"
  dimensions = {
    VolumeId = aws_instance.femiwiki.root_block_device.0.volume_id
  }
  evaluation_periods  = "1"
  threshold           = "75"
  comparison_operator = "LessThanThreshold"
  datapoints_to_alarm = 1
  alarm_actions       = [aws_sns_topic.cloudwatch_alarms_topic.arn]
}
