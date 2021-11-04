locals {
  count_logging = var.enable_cwlogs == true ? 1 : 0
}

resource "aws_sns_topic" "sns_topic" {
  name = var.sns_topic_name
}

resource "aws_sns_topic_subscription" "lambda_subscription" {
  topic_arn = aws_sns_topic.sns_topic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.lambda_function.arn
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = 14
}

data "aws_iam_policy_document" "iam_assume_policy_lambda" {

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "iam_role_lambda_logging" {
  name = "iam_role_lambda_for_${var.function_name}"

  assume_role_policy = data.aws_iam_policy_document.iam_assume_policy_lambda.json
}

data "aws_iam_policy_document" "iam_policy_document_lambda_logging" {

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:aws:logs:ap-northeast-1:${var.aws_account_id}:log-group:/aws/lambda/${var.function_name}:*"
    ]
  }
}

resource "aws_iam_policy" "iam_policy_lambda_logging" {
  name = "iam_policy_lambda_for_${var.function_name}"

  policy = data.aws_iam_policy_document.iam_policy_document_lambda_logging.json
}

data "aws_iam_policy_document" "iam_policy_document_lambda" {

  statement {
    effect = "Allow"
    actions = [
      "logs:FilterLogEvents",
      "logs:DescribeSubscriptionFilters",
      "logs:DescribeMetricFilters",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "iam_policy_lambda_default" {
  count = local.count_logging
  name  = "iam_policy_lambda_for_${var.function_name}_default"

  policy = data.aws_iam_policy_document.iam_policy_document_lambda.json
}

resource "aws_iam_role_policy_attachment" "role_policy_attachment_1" {
  role       = aws_iam_role.iam_role_lambda_logging.name
  policy_arn = aws_iam_policy.iam_policy_lambda_logging.arn
}

resource "aws_iam_role_policy_attachment" "role_policy_attachment_lambda" {
  count      = local.count_logging
  role       = aws_iam_role.iam_role_lambda_logging.name
  policy_arn = aws_iam_policy.iam_policy_lambda_default[0].arn
}

resource "aws_lambda_function" "lambda_function" {
  function_name = var.function_name

  filename = var.lambda_source
  runtime  = var.lambda_runtime
  handler  = var.lambda_handler
  timeout  = var.lambda_timeout
  layers   = var.layer_arns

  source_code_hash = var.lambda_hash

  role = aws_iam_role.iam_role_lambda_logging.arn

  environment {
    variables = var.lambda_envs
  }

  lifecycle {
    ignore_changes = [
      last_modified,
      source_code_hash,
      layers,
    ]
  }
}

resource "aws_lambda_permission" "lambda_permission" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.sns_topic.arn
}

