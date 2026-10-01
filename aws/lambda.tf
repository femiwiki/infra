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
