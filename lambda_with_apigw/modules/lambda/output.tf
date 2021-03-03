output "func_arn" {
  value = aws_lambda_function.default.arn
}

output "func_uri" {
  value = aws_lambda_function.default.invoke_arn
}