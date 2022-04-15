resource "aws_cloudwatch_metric_alarm" "femiwiki_cpu_credit_balance_cloud_watch_alarm" {
  alarm_name  = "Femiwiki CPU credit balance"
  namespace   = "AWS/EC2"
  metric_name = "CPUCreditBalance"
  period      = 300
  statistic   = "Minimum"
  dimensions = {
    InstanceId = aws_instance.femiwiki.id
  }
  threshold           = 72
  comparison_operator = "LessThanThreshold"
  datapoints_to_alarm = 1
  evaluation_periods  = 1
  alarm_actions       = [aws_sns_topic.cloudwatch_alarms_topic.arn]
}

resource "aws_cloudwatch_metric_alarm" "femiwiki_volume_idle_time_cloud_watch_alarm" {
  alarm_name  = "Femiwiki VolumeIdleTime"
  namespace   = "AWS/EBS"
  metric_name = "VolumeIdleTime"
  period      = 300
  statistic   = "Minimum"
  dimensions = {
    VolumeId = aws_instance.femiwiki.root_block_device[0].volume_id
  }
  threshold           = 20
  comparison_operator = "LessThanThreshold"
  datapoints_to_alarm = 2
  evaluation_periods  = 2
  alarm_actions       = [aws_sns_topic.cloudwatch_alarms_topic.arn]
}

resource "aws_cloudwatch_metric_alarm" "femiwiki_disk_used_cloud_watch_alarm" {
  alarm_name  = "Femiwiki disk used"
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
  threshold           = 90
  comparison_operator = "GreaterThanThreshold"
  datapoints_to_alarm = 1
  evaluation_periods  = 1
  alarm_actions       = [aws_sns_topic.cloudwatch_alarms_topic.arn]
}

resource "aws_cloudwatch_metric_alarm" "bounce_rate" {
  provider = aws.us

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
}

resource "aws_cloudwatch_metric_alarm" "complaint_rate" {
  provider = aws.us

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
}

resource "aws_cloudwatch_metric_alarm" "femiwiki_main_page" {
  provider = aws.us

  alarm_name  = "Femiwiki_Main_Page-awsroute53-Low-HealthCheckStatus"
  namespace   = "AWS/Route53"
  metric_name = "HealthCheckStatus"
  period      = 60
  statistic   = "Minimum"
  dimensions = {
    HealthCheckId = aws_route53_health_check.femiwiki_main_page.id
  }
  threshold           = 1
  comparison_operator = "LessThanThreshold"
  datapoints_to_alarm = 1
  evaluation_periods  = 1
  alarm_actions       = [aws_sns_topic.cloudwatch_alarms_topic_us.arn]
  ok_actions          = [aws_sns_topic.cloudwatch_alarms_topic_us.arn]
}
