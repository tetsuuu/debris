// CloudWatch Logsから受け取るKinesis Data Stream
resource "aws_kinesis_stream" "kinesis_stream_datadog" {
  name             = "${var.app_name}LogStream"
  retention_period = 24
  shard_count      = 1
}

// Datadogに送るKinesis Firehose Stream
resource "aws_kinesis_firehose_delivery_stream" "kinesis_firehose_stream_datadog" {
  name        = "${var.app_name}Logsforwarder"
  destination = "http_endpoint"

  http_endpoint_configuration {
    name               = "Datadog"
    url                = "https://aws-kinesis-http-intake.logs.datadoghq.com/v1/input"
    access_key         = var.api_key
    buffering_size     = 4
    buffering_interval = 60
    retry_duration     = 60
    role_arn           = aws_iam_role.iam_role_kinesis_datadog_forward.arn
    s3_backup_mode     = "FailedDataOnly"

    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = "/aws/kinesisfirehose/DatadogLogsforwarder"
      log_stream_name = "${var.app_name}DeliveryFailed"
    }

    processing_configuration {
      enabled = false
    }

    request_configuration {
      content_encoding = "GZIP"

      common_attributes {
        name  = "Env"
        value = "dev"
      }

      common_attributes {
        name  = "Name"
        value = var.app_name
      }
    }
  }

  kinesis_source_configuration {
    kinesis_stream_arn = aws_kinesis_stream.kinesis_stream_datadog.arn
    role_arn           = aws_iam_role.iam_role_kinesis_datadog_forward.arn
  }

  s3_configuration {
    bucket_arn         = "arn:aws:s3:::${var.s3_bucket}"
    buffer_interval    = 300
    buffer_size        = 5
    compression_format = "GZIP"
    role_arn           = aws_iam_role.iam_role_kinesis_datadog_forward.arn

    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = "/aws/kinesisfirehose/DatadogLogsforwarder"
      log_stream_name = "${var.app_name}Delivery"
    }
  }
}

// CloudWatchサブスクリプションフィルター (送るログの条件)
resource "aws_cloudwatch_log_subscription_filter" "log_subscription_filter_fuga" {
  name            = "${var.app_name}PutDatastream"
  role_arn        = aws_iam_role.iam_role_assume_cloudwatch_logs.arn
  log_group_name  = var.app_log_group
  filter_pattern  = var.filter_pattern
  destination_arn = aws_kinesis_stream.kinesis_stream_datadog.arn
  distribution    = "Random"
}
