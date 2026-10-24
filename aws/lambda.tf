resource "aws_lambda_function" "mastodon_discord" {
  function_name = "mastodon-discord"
  description   = "Relays mentions of the wiki's Mastodon status account to Discord. Code: femiwiki/lambda."
  role          = module.mastodon_discord.arn
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

module "mastodon_discord" {
  source                   = "terraform-aws-modules/iam/aws//modules/iam-role"
  version                  = "6.8.2"
  name                     = "mastodon-discord"
  use_name_prefix          = false
  description              = "Execution role for the mastodon-discord Lambda function."
  trust_policy_permissions = local.lambda_trust
}

resource "aws_iam_role_policy" "mastodon_discord" {
  name   = "MastodonDiscord"
  role   = module.mastodon_discord.name
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

resource "aws_lambda_function" "mastodon_boost" {
  function_name = "mastodon-boost"
  description   = "Boosts mentions of the wiki's Mastodon status account from trusted accounts. Code: femiwiki/lambda."
  role          = module.mastodon_boost.arn
  runtime       = "python3.13"
  architectures = ["arm64"]
  handler       = "lambda_function.lambda_handler"
  filename      = "${path.module}/res/lambda-placeholder.zip"
  timeout       = 30
  memory_size   = 128

  lifecycle {
    ignore_changes = [filename, source_code_hash, environment]
  }

  depends_on = [aws_cloudwatch_log_group.mastodon_boost]
}

resource "aws_cloudwatch_log_group" "mastodon_boost" {
  name              = "/aws/lambda/mastodon-boost"
  retention_in_days = 14
}

module "mastodon_boost" {
  source                   = "terraform-aws-modules/iam/aws//modules/iam-role"
  version                  = "6.8.2"
  name                     = "mastodon-boost"
  use_name_prefix          = false
  description              = "Execution role for the mastodon-boost Lambda function."
  trust_policy_permissions = local.lambda_trust
}

resource "aws_iam_role_policy" "mastodon_boost" {
  name   = "MastodonBoost"
  role   = module.mastodon_boost.name
  policy = data.aws_iam_policy_document.mastodon_boost.json
}

data "aws_iam_policy_document" "mastodon_boost" {
  statement {
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.mastodon_boost.arn}:*"]
  }

  statement {
    actions   = ["ssm:GetParameter", "ssm:PutParameter"]
    resources = ["arn:aws:ssm:${local.seoul_region}:${data.aws_caller_identity.current.account_id}:parameter/mastodon-boost/cursor"]
  }
}

resource "aws_cloudwatch_event_rule" "mastodon_boost" {
  name                = "mastodon-boost"
  description         = "Runs the mastodon-boost Lambda function every minute."
  schedule_expression = "rate(1 minute)"
}

resource "aws_cloudwatch_event_target" "mastodon_boost" {
  rule = aws_cloudwatch_event_rule.mastodon_boost.name
  arn  = aws_lambda_function.mastodon_boost.arn
}

resource "aws_lambda_permission" "mastodon_boost" {
  statement_id  = "AllowEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.mastodon_boost.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.mastodon_boost.arn
}

resource "aws_lambda_function" "grafana_github" {
  function_name = "grafana-github"
  description   = "Opens a GitHub issue per Grafana alert rule that only operators need to act on. Code: femiwiki/lambda."
  role          = module.grafana_github.arn
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

module "grafana_github" {
  source                   = "terraform-aws-modules/iam/aws//modules/iam-role"
  version                  = "6.8.2"
  name                     = "grafana-github"
  use_name_prefix          = false
  description              = "Execution role for the grafana-github Lambda function."
  trust_policy_permissions = local.lambda_trust
}

resource "aws_iam_role_policy" "grafana_github" {
  name   = "GrafanaGithub"
  role   = module.grafana_github.name
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
  role          = module.sns_discord.arn
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

module "sns_discord" {
  source                   = "terraform-aws-modules/iam/aws//modules/iam-role"
  version                  = "6.8.2"
  name                     = "sns-discord"
  use_name_prefix          = false
  description              = "Execution role for the sns-discord Lambda function."
  trust_policy_permissions = local.lambda_trust
}

resource "aws_iam_role_policy" "sns_discord" {
  name   = "SnsDiscord"
  role   = module.sns_discord.name
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

resource "aws_sns_topic_subscription" "sns_discord_seoul" {
  topic_arn = aws_sns_topic.cloudwatch_alarms.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.sns_discord.arn
}

resource "aws_lambda_permission" "sns_discord_seoul" {
  statement_id  = "AllowSNSSeoul"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sns_discord.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.cloudwatch_alarms.arn
}

resource "aws_sns_topic_subscription" "sns_discord_ok" {
  topic_arn = aws_sns_topic.cloudwatch_ok.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.sns_discord.arn
}

resource "aws_lambda_permission" "sns_discord_ok" {
  statement_id  = "AllowSNSOk"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sns_discord.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.cloudwatch_ok.arn
}

resource "aws_lambda_function" "bounce_handler" {
  function_name = "bounce-handler"
  description   = "Hands SES permanent bounces to MediaWiki's BounceHandler API. Code: femiwiki/lambda."
  role          = module.bounce_handler.arn
  runtime       = "python3.13"
  architectures = ["arm64"]
  handler       = "lambda_function.lambda_handler"
  filename      = "${path.module}/res/lambda-placeholder.zip"
  timeout       = 30
  memory_size   = 128

  lifecycle {
    ignore_changes = [filename, source_code_hash, environment]
  }

  depends_on = [aws_cloudwatch_log_group.bounce_handler]
}

resource "aws_cloudwatch_log_group" "bounce_handler" {
  name              = "/aws/lambda/bounce-handler"
  retention_in_days = 14
}

module "bounce_handler" {
  source                   = "terraform-aws-modules/iam/aws//modules/iam-role"
  version                  = "6.8.2"
  name                     = "bounce-handler"
  use_name_prefix          = false
  description              = "Execution role for the bounce-handler Lambda function."
  trust_policy_permissions = local.lambda_trust
}

resource "aws_iam_role_policy" "bounce_handler" {
  name   = "BounceHandler"
  role   = module.bounce_handler.name
  policy = data.aws_iam_policy_document.bounce_handler.json
}

data "aws_iam_policy_document" "bounce_handler" {
  statement {
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.bounce_handler.arn}:*"]
  }

  statement {
    actions   = ["ssm:GetParameter"]
    resources = [data.aws_ssm_parameter.secret["/mediawiki/bounce_handler/token"].arn]
  }
}

resource "aws_sns_topic_subscription" "bounce_handler" {
  region    = "us-east-1"
  topic_arn = aws_sns_topic.ses_bounces.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.bounce_handler.arn
}

resource "aws_lambda_permission" "bounce_handler" {
  statement_id  = "AllowSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.bounce_handler.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.ses_bounces.arn
}
