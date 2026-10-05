# Query the CloudFront logs by hour (UTC): a WHERE on year, month, day and hour
# reads only those partitions, and Parquet reads only the columns selected.
resource "aws_glue_catalog_database" "logs" {
  region = local.seoul_region
  name   = "logs"
}

resource "aws_glue_catalog_table" "cloudfront" {
  region        = local.seoul_region
  database_name = aws_glue_catalog_database.logs.name
  name          = "cloudfront"
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    "classification"            = "parquet"
    "projection.enabled"        = "true"
    "projection.year.type"      = "integer"
    "projection.year.range"     = "2026,2036"
    "projection.month.type"     = "integer"
    "projection.month.range"    = "1,12"
    "projection.month.digits"   = "2"
    "projection.day.type"       = "integer"
    "projection.day.range"      = "1,31"
    "projection.day.digits"     = "2"
    "projection.hour.type"      = "integer"
    "projection.hour.range"     = "0,23"
    "projection.hour.digits"    = "2"
    "storage.location.template" = "s3://${aws_s3_bucket.edge_logs.id}/cloudfront/year=$${year}/month=$${month}/day=$${day}/hour=$${hour}/"
  }

  dynamic "partition_keys" {
    for_each = ["year", "month", "day", "hour"]

    content {
      name = partition_keys.value
      type = "int"
    }
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.edge_logs.id}/cloudfront/"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
    }

    # The delivery's record_fields, as CloudFront names them in Parquet
    dynamic "columns" {
      for_each = [for f in aws_cloudwatch_log_delivery.femiwiki_com.record_fields : lower(replace(replace(replace(f, "-", "_"), "(", "_"), ")", ""))]

      content {
        name = columns.value
        type = "string"
      }
    }
  }
}

resource "aws_athena_workgroup" "logs" {
  region = local.seoul_region
  name   = "logs"

  configuration {
    enforce_workgroup_configuration = true
    # 1 GiB is $0.005 and about eight days of every column
    bytes_scanned_cutoff_per_query = 1073741824

    result_configuration {
      output_location = "s3://${aws_s3_bucket.edge_logs.id}/athena-results/"

      encryption_configuration {
        encryption_option = "SSE_S3"
      }
    }
  }
}
