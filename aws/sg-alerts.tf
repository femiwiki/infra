# An issue through grafana-github whenever a call opens an inbound rule to everyone
# (femiwiki/femiwiki#514). The calls come from aws_cloudtrail.management_events.
locals {
  security_group_rule_calls = jsonencode({
    source        = ["aws.ec2"]
    "detail-type" = ["AWS API Call via CloudTrail"]
    detail = {
      eventSource = ["ec2.amazonaws.com"]
      eventName   = ["AuthorizeSecurityGroupIngress", "ModifySecurityGroupRules"]
      errorCode   = [{ exists = false }]
    }
  })
  seoul_default_event_bus = "arn:aws:events:${local.seoul_region}:${data.aws_caller_identity.current.account_id}:event-bus/default"
}

# Seoul's own calls, and Tokyo's forwarded below.
resource "aws_cloudwatch_event_rule" "security_group_rules" {
  name          = "security-group-rules"
  description   = "Sends security group rule changes in Seoul and Tokyo to the grafana-github Lambda function."
  event_pattern = local.security_group_rule_calls
}

resource "aws_cloudwatch_event_target" "security_group_rules" {
  rule = aws_cloudwatch_event_rule.security_group_rules.name
  arn  = aws_lambda_function.grafana_github.arn
}

resource "aws_lambda_permission" "grafana_github_security_group_rules" {
  statement_id  = "AllowEventBridgeSecurityGroupRules"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.grafana_github.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.security_group_rules.arn
}

# A rule cannot invoke a function in another region, only an event bus.
resource "aws_cloudwatch_event_rule" "security_group_rules_tokyo" {
  region        = local.tokyo_region
  name          = "security-group-rules"
  description   = "Forwards security group rule changes in Tokyo to the Seoul default event bus."
  event_pattern = local.security_group_rule_calls
}

resource "aws_cloudwatch_event_target" "security_group_rules_tokyo" {
  region   = local.tokyo_region
  rule     = aws_cloudwatch_event_rule.security_group_rules_tokyo.name
  arn      = local.seoul_default_event_bus
  role_arn = module.security_group_rules_tokyo.arn
}

module "security_group_rules_tokyo" {
  source          = "terraform-aws-modules/iam/aws//modules/iam-role"
  version         = "6.8.2"
  name            = "security-group-rules-tokyo"
  use_name_prefix = false
  description     = "Lets EventBridge in Tokyo forward security group rule changes to Seoul."
  trust_policy_permissions = {
    EventBridgeAssumeRole = {
      actions    = ["sts:AssumeRole"]
      principals = [{ type = "Service", identifiers = ["events.amazonaws.com"] }]
    }
  }
}

resource "aws_iam_role_policy" "security_group_rules_tokyo" {
  name   = "ForwardToSeoul"
  role   = module.security_group_rules_tokyo.name
  policy = data.aws_iam_policy_document.security_group_rules_tokyo.json
}

data "aws_iam_policy_document" "security_group_rules_tokyo" {
  statement {
    actions   = ["events:PutEvents"]
    resources = [local.seoul_default_event_bus]
  }
}
