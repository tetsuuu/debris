// CloudWatch Logsサブスクリプションフィルター用 IAMリソース
data "aws_iam_policy_document" "iam_role_assume_cloudwatchlogs" {

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["logs.ap-northeast-1.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "iam_policy_cloudwatchlogs_put_kinesis" {

  statement {
    effect = "Allow"
    actions = [
      "kinesis:PutRecord",
      "kinesis:PutRecordBatch",
      "firehose:PutRecord",
      "firehose:PutRecordBatch",
    ]

    resources = ["arn:aws:kinesis:ap-northeast-1:${var.account_id}:stream/${var.app_name}LogStream"]
  }
}

resource "aws_iam_role" "iam_role_assume_cloudwatch_logs" {
  name = "${var.app_name}CloudWatchLogsAssumeRole"

  assume_role_policy = data.aws_iam_policy_document.iam_role_assume_cloudwatchlogs.json
}

resource "aws_iam_policy" "iam_policy_cloudwatch_logs_kinesis" {
  name   = "${var.app_name}CloudWatchLogsPutKinesis"
  policy = data.aws_iam_policy_document.iam_policy_cloudwatchlogs_put_kinesis.json
}

resource "aws_iam_role_policy_attachment" "iam_attach_policy_cloudwatchlogs_kinesis" {
  role       = aws_iam_role.iam_role_assume_cloudwatch_logs.name
  policy_arn = aws_iam_policy.iam_policy_cloudwatch_logs_kinesis.arn
}

// Kinesis Friehose Stream用 IAMリソース
data "aws_iam_policy_document" "kinesis_policy" {

  statement {
    effect = "Allow"
    actions = [
      "glue:GetTable",
      "glue:GetTableVersion",
      "glue:GetTableVersions",
    ]

    resources = [
      "arn:aws:glue:ap-northeast-1:${var.account_id}:catalog",
      "arn:aws:glue:ap-northeast-1:${var.account_id}:database/%FIREHOSE_POLICY_TEMPLATE_PLACEHOLDER%",
      "arn:aws:glue:ap-northeast-1:${var.account_id}:table/%FIREHOSE_POLICY_TEMPLATE_PLACEHOLDER%/%FIREHOSE_POLICY_TEMPLATE_PLACEHOLDER%",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::${var.s3_bucket}",
      "arn:aws:s3:::${var.s3_bucket}/*",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction",
      "lambda:GetFunctionConfiguration",
    ]

    resources = [
      "arn:aws:lambda:ap-northeast-1:${var.account_id}:function:%FIREHOSE_POLICY_TEMPLATE_PLACEHOLDER%",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "kms:GenerateDataKey",
      "kms:Decrypt",
    ]

    resources = [
      "arn:aws:kms:ap-northeast-1:${var.account_id}:key/%FIREHOSE_POLICY_TEMPLATE_PLACEHOLDER%",
    ]

    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values = [
        "s3.ap-northeast-1.amazonaws.com",
      ]
    }

    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:s3:arn"
      values = [
        "arn:aws:s3:::%FIREHOSE_POLICY_TEMPLATE_PLACEHOLDER%/*",
      ]
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:aws:logs:ap-northeast-1:${var.account_id}:log-group:/aws/kinesisfirehose/DatadogLogsforwarder:log-stream:*",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "kinesis:DescribeStream",
      "kinesis:GetShardIterator",
      "kinesis:GetRecords",
      "kinesis:ListShards",
    ]

    resources = [
      aws_kinesis_stream.kinesis_stream_datadog.arn,
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
    ]

    resources = [
      "arn:aws:kms:ap-northeast-1:${var.account_id}:key/%FIREHOSE_POLICY_TEMPLATE_PLACEHOLDER%",
    ]

    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values = [
        "kinesis.ap-northeast-1.amazonaws.com",
      ]
    }

    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:kinesis:arn"
      values = [
        aws_kinesis_stream.kinesis_stream_datadog.arn,
      ]
    }
  }
}

resource "aws_iam_policy" "iam_policy_kinesis_datadog_forward" {
  name   = "${var.app_name}KinesisFirehoseServicePolicy"
  policy = data.aws_iam_policy_document.kinesis_policy.json
}

data "aws_iam_policy_document" "kinesis_role" {

  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type = "Service"
      identifiers = [
        "firehose.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "iam_role_kinesis_datadog_forward" {
  name = "${var.app_name}KinesisFirehoseServiceRole"

  assume_role_policy = data.aws_iam_policy_document.kinesis_role.json
}

resource "aws_iam_role_policy_attachment" "iam_attach_policy_kinesis_datadog_forward" {
  role       = aws_iam_role.iam_role_kinesis_datadog_forward.name
  policy_arn = aws_iam_policy.iam_policy_kinesis_datadog_forward.arn
}

