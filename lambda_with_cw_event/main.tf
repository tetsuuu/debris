module "lambda_source_sample" {
  source = "./lambda_source"

  function_name    = "sample"
  lambda_file_name = "sample.py"
}

module "notify_sample" {
  source = "./lambda_with_events"

  aws_account_id = data.aws_caller_identity.self.account_id

  function_name  = "notify_sample"
  lambda_hash    = module.lambda_source_sample.lambda_hash
  lambda_source  = module.lambda_source_sample.lambda_archive
  lambda_runtime = "python3.8"
  lambda_handler = "sample.lambda_handler"

  layer_arns = [
    "arn:aws:lambda:ap-northeast-1:770693421928:layer:Klayers-python38-requests:22",
  ]

  lambda_envs = {
    SLACK_WEBHOOK_URL = ""
    SLACK_CHANNEL     = "notify_alarm"
    MAXIMUM_LOGS      = 10
  }

  enable_cwlogs = true

  sns_topic_name = "sns_notify_sample"
}

module "cloudwatch_alarm_sapmle" {
  source = "./cw_alerm"

  cw_filter_name      = "sampleAlarmDetect"
  cw_filter_namespace = "Application"
  cw_filter_pattern   = <<EOF
  "[9, 0, 4, 7]"
EOF

  cw_log_group_name = "fizz/buzz"
  cw_default_metric = "0"

  cw_alarm_name      = "sampleアラーム検知(sample)"
  cw_alarm_operator  = "GreaterThanOrEqualToThreshold"
  cw_alarm_statistic = "Sum"
  cw_alarm_period    = 60

  sns_topic_arns = [
    module.notify_sample.sns_topic_arn
  ]
}
