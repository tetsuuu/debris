resource "aws_s3_bucket" "s3_bucket_terraform" {
  bucket        = "${var.service_name}.${var.env}.com"
  force_destroy = false

  versioning {
    enabled    = true
    mfa_delete = false
  }
}

resource "aws_s3_bucket_public_access_block" "s3_bucket_terraform" {
  bucket = aws_s3_bucket.s3_bucket_terraform.bucket

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
