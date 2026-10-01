resource "aws_lambda_function" "mastodon_discord" {
  function_name = "mastodon-discord"
  description   = "Relays mentions of the wiki's Mastodon status account to Discord. Code: femiwiki/lambda."
  role          = aws_iam_role.mastodon_discord.arn
  runtime       = "python3.13"
  architectures = ["arm64"]
  handler       = "lambda_function.lambda_handler"
  filename      = "${path.module}/res/lambda-placeholder.zip"
  timeout       = 30
  memory_size   = 128

  lifecycle {
    ignore_changes = [filename, source_code_hash, environment]
  }

  depends_on = [aws_cloudwatch_log_group.mastodon_discord]
}

resource "aws_cloudwatch_log_group" "mastodon_discord" {
  name              = "/aws/lambda/mastodon-discord"
  retention_in_days = 14
}

resource "aws_iam_role" "mastodon_discord" {
  name               = "mastodon-discord"
  description        = "Execution role for the mastodon-discord Lambda function."
  assume_role_policy = data.aws_iam_policy_document.discord_noti_assume_role.json
}

resource "aws_iam_role_policy" "mastodon_discord" {
  name   = "MastodonDiscord"
  role   = aws_iam_role.mastodon_discord.name
  policy = data.aws_iam_policy_document.mastodon_discord.json
}

data "aws_iam_policy_document" "mastodon_discord" {
  statement {
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.mastodon_discord.arn}:*"]
  }

  statement {
    actions   = ["ssm:GetParameter", "ssm:PutParameter"]
    resources = ["arn:aws:ssm:${local.seoul_region}:${data.aws_caller_identity.current.account_id}:parameter/mastodon-discord/cursor"]
  }
}

resource "aws_cloudwatch_event_rule" "mastodon_discord" {
  name                = "mastodon-discord"
  description         = "Runs the mastodon-discord Lambda function every minute."
  schedule_expression = "rate(1 minute)"
}

resource "aws_cloudwatch_event_target" "mastodon_discord" {
  rule = aws_cloudwatch_event_rule.mastodon_discord.name
  arn  = aws_lambda_function.mastodon_discord.arn
}

resource "aws_lambda_permission" "mastodon_discord" {
  statement_id  = "AllowEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.mastodon_discord.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.mastodon_discord.arn
}

resource "aws_lambda_function" "grafana_github" {
  function_name = "grafana-github"
  description   = "Opens a GitHub issue per Grafana alert rule that only operators need to act on. Code: femiwiki/lambda."
  role          = aws_iam_role.grafana_github.arn
  runtime       = "python3.13"
  architectures = ["arm64"]
  handler       = "lambda_function.lambda_handler"
  filename      = "${path.module}/res/lambda-placeholder.zip"
  timeout       = 30
  memory_size   = 128

  lifecycle {
    ignore_changes = [filename, source_code_hash, environment]
  }

  depends_on = [aws_cloudwatch_log_group.grafana_github]
}

resource "aws_cloudwatch_log_group" "grafana_github" {
  name              = "/aws/lambda/grafana-github"
  retention_in_days = 14
}

resource "aws_iam_role" "grafana_github" {
  name               = "grafana-github"
  description        = "Execution role for the grafana-github Lambda function."
  assume_role_policy = data.aws_iam_policy_document.discord_noti_assume_role.json
}

resource "aws_iam_role_policy" "grafana_github" {
  name   = "GrafanaGithub"
  role   = aws_iam_role.grafana_github.name
  policy = data.aws_iam_policy_document.grafana_github.json
}

data "aws_iam_policy_document" "grafana_github" {
  statement {
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.grafana_github.arn}:*"]
  }
}

# Grafana cannot sign AWS requests, so the function checks a bearer token itself.
resource "aws_lambda_function_url" "grafana_github" {
  function_name      = aws_lambda_function.grafana_github.function_name
  authorization_type = "NONE"
}

resource "aws_lambda_permission" "grafana_github" {
  for_each = {
    AllowFunctionUrl      = "lambda:InvokeFunctionUrl"
    AllowInvokeThroughUrl = "lambda:InvokeFunction"
  }

  statement_id             = each.key
  action                   = each.value
  function_name            = aws_lambda_function.grafana_github.function_name
  principal                = "*"
  function_url_auth_type   = each.value == "lambda:InvokeFunctionUrl" ? "NONE" : null
  invoked_via_function_url = each.value == "lambda:InvokeFunction" ? true : null
}

resource "aws_lambda_function" "sns_discord" {
  function_name = "sns-discord"
  description   = "Posts CloudWatch alarm notifications from SNS to Discord. Code: femiwiki/lambda."
  role          = aws_iam_role.sns_discord.arn
  runtime       = "python3.13"
  architectures = ["arm64"]
  handler       = "lambda_function.lambda_handler"
  filename      = "${path.module}/res/lambda-placeholder.zip"
  timeout       = 30
  memory_size   = 128

  lifecycle {
    ignore_changes = [filename, source_code_hash, environment]
  }

  depends_on = [aws_cloudwatch_log_group.sns_discord]
}

resource "aws_cloudwatch_log_group" "sns_discord" {
  name              = "/aws/lambda/sns-discord"
  retention_in_days = 14
}

resource "aws_iam_role" "sns_discord" {
  name               = "sns-discord"
  description        = "Execution role for the sns-discord Lambda function."
  assume_role_policy = data.aws_iam_policy_document.discord_noti_assume_role.json
}

resource "aws_iam_role_policy" "sns_discord" {
  name   = "SnsDiscord"
  role   = aws_iam_role.sns_discord.name
  policy = data.aws_iam_policy_document.sns_discord.json
}

data "aws_iam_policy_document" "sns_discord" {
  statement {
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.sns_discord.arn}:*"]
  }

  statement {
    # GetMetricWidgetImage does not support resource-level permissions.
    actions   = ["cloudwatch:GetMetricWidgetImage"]
    resources = ["*"]
  }
}

# The Route 53 and SES alarms can only live in us-east-1, so their topic calls
# the function across regions.
resource "aws_sns_topic_subscription" "sns_discord" {
  region    = "us-east-1"
  topic_arn = aws_sns_topic.cloudwatch_alarms_topic_us.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.sns_discord.arn
}

resource "aws_lambda_permission" "sns_discord" {
  statement_id  = "AllowSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sns_discord.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.cloudwatch_alarms_topic_us.arn
}
