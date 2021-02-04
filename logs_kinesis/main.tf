module "hoge_kinesis" {
  source = "./modules/kinesis_stream"

  account_id     = data.aws_caller_identity.self.account_id
  api_key        = "fizzbuzz"
  app_log_group  = "fizzbuzz-LogGroup"
  app_name       = "hoge"
  filter_pattern = "[ date, timestamp, status = *INFO* || status = *WARN* ||  status = *ERROR*, ...]"
  s3_bucket      = "datastream.env"
}

resource "aws_cloudwatch_log_group" "kinesis_datadog_forward" {
  name = "/aws/kinesisfirehose/DatadogLogsforwarder"
}
