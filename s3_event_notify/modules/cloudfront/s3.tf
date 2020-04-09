resource "aws_s3_bucket" "default" {
  bucket        = "${var.bucket_name}.${var.delegate_domain}"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "default" {
  bucket = aws_s3_bucket.default.bucket

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "default" {

  statement {
    sid     = "ReadAccess"
    effect  = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
    ]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.default.iam_arn]
    }

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.default.bucket}",
      "arn:aws:s3:::${aws_s3_bucket.default.bucket}/*",
    ]
  }
}

resource "aws_s3_bucket_policy" "default" {
  bucket = aws_s3_bucket.default.bucket
  policy = data.aws_iam_policy_document.default.json
}

resource "aws_s3_bucket_notification" "s3_event_lambda" {
  bucket = aws_s3_bucket.default.bucket

  lambda_function {
    id                  = var.func_name
    lambda_function_arn = var.func_arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "reports/"
    filter_suffix       = ".csv"
  }

  depends_on = [var.assume_lambda]
}
