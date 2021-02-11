resource "aws_cloudformation_stack" "datadog_forwarder" {
  name         = "datadog-forwarder"
  template_url = "https://datadog-cloudformation-template.s3.amazonaws.com/aws/forwarder/3.28.4.yaml"

  capabilities = [
    "CAPABILITY_IAM",
    "CAPABILITY_NAMED_IAM",
    "CAPABILITY_AUTO_EXPAND"
  ]

  parameters = {
    DdSite            = "datadoghq.com"
    DdApiKey          = "this_value_is_not_used"
    DdApiKeySecretArn = aws_secretsmanager_secret.secret_datadog_api_key.arn
    FunctionName      = "datadog_forwarder"
    DdTags            = "role:${var.role}"
    ExcludeAtMatch    = var.filter_pattern
  }
}

resource "aws_secretsmanager_secret" "secret_datadog_api_key" {
  name                    = "secrets/dd_api_key"
  description             = "Encrypted Datadog API Key"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "secret_version_datadog_api_key" {
  secret_id     = aws_secretsmanager_secret.secret_datadog_api_key.id
  secret_string = var.api_key
}

data "aws_cloudformation_export" "lambda_arn" {
  name = "datadog-forwarder-ForwarderArn"
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = var.s3_bucket

  dynamic "lambda_function" {
    for_each = var.bucket_prefix

    content {
      lambda_function_arn = data.aws_cloudformation_export.lambda_arn.value
      events              = ["s3:ObjectCreated:*"]
      filter_prefix       = lambda_function.value
    }
  }
}

data "aws_s3_bucket" "s3_bucket_buzz" {
  bucket = var.s3_bucket
}

resource "aws_lambda_permission" "lambda_permission" {
  action        = "lambda:InvokeFunction"
  function_name = data.aws_cloudformation_export.lambda_arn.value
  principal     = "s3.amazonaws.com"
  source_arn    = data.aws_s3_bucket.s3_bucket_buzz.arn
}
