resource "aws_bcmdataexports_export" "cost_and_usage" {
  provider = aws.us

  export {
    name        = "femiwiki-cost-and-usage"
    description = "Monthly line items for femiwiki.github.io"

    data_query {
      query_statement = "SELECT bill_billing_period_start_date, line_item_line_item_type, line_item_product_code, product_servicecode, product_product_family, product_region_code, product_location, line_item_usage_type, line_item_line_item_description, line_item_usage_amount, pricing_unit, line_item_unblended_cost, line_item_net_unblended_cost FROM COST_AND_USAGE_REPORT"
      table_configurations = {
        COST_AND_USAGE_REPORT = {
          BILLING_VIEW_ARN                      = "arn:aws:billing::${data.aws_caller_identity.current.account_id}:billingview/primary"
          TIME_GRANULARITY                      = "MONTHLY"
          INCLUDE_RESOURCES                     = "FALSE"
          INCLUDE_MANUAL_DISCOUNT_COMPATIBILITY = "FALSE"
          INCLUDE_SPLIT_COST_ALLOCATION_DATA    = "FALSE"
        }
      }
    }

    destination_configurations {
      s3_destination {
        s3_bucket = aws_s3_bucket.cost_exports.bucket
        s3_prefix = "cost-and-usage"
        s3_region = data.aws_region.current.region

        s3_output_configurations {
          overwrite   = "OVERWRITE_REPORT"
          format      = "TEXT_OR_CSV"
          compression = "GZIP"
          output_type = "CUSTOM"
        }
      }
    }

    refresh_cadence {
      frequency = "SYNCHRONOUS"
    }
  }

  depends_on = [aws_s3_bucket_policy.cost_exports]
}
