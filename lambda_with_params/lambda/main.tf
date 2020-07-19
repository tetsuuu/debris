data "aws_iam_policy_document" "lambda_role" {

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda_policy" {

  statement {
    effect  = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:aws:logs:ap-northeast-1:${var.account_id}:log-group:/aws/lambda/${var.func_name}:*",
    ]
  }
}

data "aws_iam_policy_document" "lambda_ssm_policy" {

  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameters",
      "ssm:GetParameter",
    ]

    resources = [
      "arn:aws:ssm:ap-northeast-1:${var.account_id}:parameter/${var.param_name}",
    ]
  }
}

data "aws_iam_policy_document" "lambda_eni_policy" {

  statement {
    effect = "Allow"
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
    ]

    resources = [
      "*",
    ]
  }
}

data "archive_file" "lambda_func" {
  type        = "zip"
  source_file = "${path.module}/src/${var.func_name}.py"
  output_path = "${path.module}/src/${var.func_name}.lambda.zip"
}

resource "aws_iam_role" "lambda_role" {
  name               = var.func_name
  assume_role_policy = data.aws_iam_policy_document.lambda_role.json
}

resource "aws_iam_policy" "lambda_policy" {
  name   = var.func_name
  policy = data.aws_iam_policy_document.lambda_policy.json
}

resource "aws_iam_policy" "lambda_ssm_policy" {
  name   = "${var.func_name}_ssm"
  policy = data.aws_iam_policy_document.lambda_ssm_policy.json
}

resource "aws_iam_policy" "lambda_eni_policy" {
  name   = "${var.func_name}_eni"
  policy = data.aws_iam_policy_document.lambda_eni_policy.json
}

resource "aws_iam_role_policy_attachment" "lambda" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_ssm" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_ssm_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_eni" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_eni_policy.arn
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.func_name}"
  retention_in_days = 14
}

resource "aws_lambda_function" "default" {
  function_name = var.func_name
  filename      = data.archive_file.lambda_func.output_path
  runtime       = "python3.7"
  handler       = "${var.func_name}.lambda_handler"
  role          = aws_iam_role.lambda_role.arn
  timeout       = var.timeout

  reserved_concurrent_executions = "0"

  source_code_hash = data.archive_file.lambda_func.output_base64sha256

  vpc_config {
    subnet_ids         = var.bastion_subnets
    security_group_ids = var.bastion_sg
  }

  environment {
    variables = var.lambda_env
  }

  lifecycle {
    ignore_changes = [
      last_modified,
      source_code_hash,
    ]
  }
}

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromCloudWatchEvent"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.default.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.rule.arn
}

resource "aws_cloudwatch_event_rule" "rule" {
  name                = var.cw_event_name
  description         = var.description
  schedule_expression = var.schedule_expression
}

resource "aws_cloudwatch_event_target" "target" {
  rule = aws_cloudwatch_event_rule.rule.name
  arn  = aws_lambda_function.default.arn
}
