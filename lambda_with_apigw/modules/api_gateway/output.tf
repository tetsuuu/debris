output "execution_arn" {
  value = aws_apigatewayv2_api.lambda_webhook.execution_arn
}

output "execution_url" {
  value = aws_apigatewayv2_api.lambda_webhook.api_endpoint
}
