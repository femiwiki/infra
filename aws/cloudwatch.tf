resource "aws_cloudwatch_metric_alarm" "femiwiki_cpu_credit_balance_cloud_watch_alarm" {
  alarm_name  = "Femiwiki CPU credit balance cloud watch alarm"
  namespace   = "AWS/EC2"
  metric_name = "CPUCreditBalance"
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
  namespace   = "AWS/EBS"
  metric_name = "BurstBalance"
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

resource "aws_cloudwatch_metric_alarm" "femiwiki_disk_used_cloud_watch_alarm" {
  alarm_name  = "Femiwiki disk used cloud watch alarm"
  namespace   = "CWAgent"
  metric_name = "disk_used_percent"
  period      = 300
  statistic   = "Maximum"
  dimensions = {
    "device" = "nvme0n1p1"
    "fstype" = "xfs"
    "host"   = aws_instance.femiwiki.private_dns
    "path"   = "/"
  }
  evaluation_periods  = "1"
  threshold           = "90"
  comparison_operator = "GreaterThanThreshold"
  datapoints_to_alarm = 1
  alarm_actions       = [aws_sns_topic.cloudwatch_alarms_topic.arn]
}

resource "aws_cloudwatch_metric_alarm" "bounce_rate" {
  provider = aws.us

  alarm_name          = "Bounce Rate"
  namespace           = "AWS/SES"
  metric_name         = "Reputation.BounceRate"
  period              = 300
  statistic           = "Average"
  evaluation_periods  = "1"
  threshold           = "0.05"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm = 1
  alarm_actions       = [aws_sns_topic.cloudwatch_alarms_topic_us.arn]
  treat_missing_data  = "ignore"
}

resource "aws_cloudwatch_metric_alarm" "complaint_rate" {
  provider = aws.us

  alarm_name          = "Complaint Rate"
  namespace           = "AWS/SES"
  metric_name         = "Reputation.ComplaintRate"
  period              = 300
  statistic           = "Average"
  evaluation_periods  = "1"
  threshold           = "0.001"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm = 1
  alarm_actions       = [aws_sns_topic.cloudwatch_alarms_topic_us.arn]
  treat_missing_data  = "ignore"
}

resource "aws_cloudwatch_metric_alarm" "femiwiki_main_page" {
  provider = aws.us

  alarm_name  = "Femiwiki_Main_Page-awsroute53-65854b5e-a8cb-40f7-87ba-5d3055f9effd-Low-HealthCheckStatus"
  namespace   = "AWS/Route53"
  metric_name = "HealthCheckStatus"
  period      = 60
  statistic   = "Minimum"
  dimensions = {
    HealthCheckId = "65854b5e-a8cb-40f7-87ba-5d3055f9effd"
  }
  evaluation_periods  = "1"
  threshold           = 1
  comparison_operator = "LessThanThreshold"
  datapoints_to_alarm = 1
  alarm_actions       = [aws_sns_topic.cloudwatch_alarms_topic_us.arn]
}
