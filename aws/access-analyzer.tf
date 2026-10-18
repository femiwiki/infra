# IAM roles are global, so both analyzers report them.
resource "aws_accessanalyzer_analyzer" "external" {
  analyzer_name = "external-access"
  type          = "ACCOUNT"
}

# Made in the console in 2019 (femiwiki/femiwiki#133). It still covers the Tokyo buckets.
import {
  to = aws_accessanalyzer_analyzer.external_tokyo
  id = "ConsoleAnalyzer-4d0d059b-cb56-458c-bee7-d153ecee63ff@${local.tokyo_region}"
}

resource "aws_accessanalyzer_analyzer" "external_tokyo" {
  region        = local.tokyo_region
  analyzer_name = "ConsoleAnalyzer-4d0d059b-cb56-458c-bee7-d153ecee63ff"
  type          = "ACCOUNT"
}

# Public by policy on purpose: see module.uploads_seoul.
resource "aws_accessanalyzer_archive_rule" "uploads" {
  analyzer_name = aws_accessanalyzer_analyzer.external.analyzer_name
  rule_name     = "uploads"

  filter {
    criteria = "resource"
    eq       = [module.uploads_seoul.s3_bucket_arn]
  }
}

# One issue per active finding, closed once it is not, through grafana-github.
# Only Seoul alerts: IAM roles are global and Tokyo would report them twice.
resource "aws_cloudwatch_event_rule" "access_analyzer_findings" {
  name        = "access-analyzer-findings"
  description = "Sends IAM Access Analyzer finding changes to the grafana-github Lambda function."
  event_pattern = jsonencode({
    source        = ["aws.access-analyzer"]
    "detail-type" = ["Access Analyzer Finding"]
    resources     = [aws_accessanalyzer_analyzer.external.arn]
  })
}

resource "aws_cloudwatch_event_target" "access_analyzer_findings" {
  rule = aws_cloudwatch_event_rule.access_analyzer_findings.name
  arn  = aws_lambda_function.grafana_github.arn
}

resource "aws_lambda_permission" "grafana_github_access_analyzer" {
  statement_id  = "AllowEventBridgeAccessAnalyzer"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.grafana_github.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.access_analyzer_findings.arn
}
