// 1. DD API Key登録
resource "aws_secretsmanager_secret" "secret_datadog_api_key" {
  name                    = "secrets/dd_api_key"
  description             = "Encrypted Datadog API Key"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "secret_version_datadog_api_key" {
  secret_id     = aws_secretsmanager_secret.secret_datadog_api_key.id
  secret_string = var.api_key
}

/* 2. CloudFormationでDatadog Forwarderを作成
 * 下記をベースにバケットロギングを追加したテンプレートを作成
 * https://datadog-cloudformation-template.s3.amazonaws.com/aws/forwarder/${var.dd_version}.yaml
 */
data "template_file" "datadog_forwarder" {
  template = file("${path.module}/template_${var.dd_version}.yaml")
}

locals {
  filter_pattern = <<EOF
php|PHP|owa|.env|HNAP1|wp-content|Joomla|joomla|login|solr|robots|bsh|widget|manager|binance|jsonws
EOF
}

resource "aws_cloudformation_stack" "datadog_forwarder" {
  name          = "datadog-forwarder"
  template_body = data.template_file.datadog_forwarder.rendered

  capabilities = [
    "CAPABILITY_IAM",
    "CAPABILITY_NAMED_IAM",
    "CAPABILITY_AUTO_EXPAND"
  ]

  parameters = {
    DdApiKey          = "dummy"
    DdApiKeySecretArn = aws_secretsmanager_secret.secret_datadog_api_key.arn
    FunctionName      = "datadog_forwarder"
    DdTags            = "role:${var.role}"
    ExcludeAtMatch    = local.filter_pattern
    LoggingBucket     = var.logging_bucket
    LogPrefix         = var.log_prefix
  }

  lifecycle {
    ignore_changes = [
      parameters,
    ]
  }
}

// 3. Datadog Forwarderをトリガーする
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
