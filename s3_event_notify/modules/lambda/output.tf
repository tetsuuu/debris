output "func_arn" {
  value = aws_lambda_function.default.arn
}

output "lambda_permission" {
  value = aws_lambda_permission.allow_s3
}

