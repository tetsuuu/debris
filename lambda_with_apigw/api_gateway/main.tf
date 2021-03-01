resource "aws_apigatewayv2_api" "lambda_webhook" {
    name                         = "lambda_with_webhook"
    description                  = "Created by AWS Lambda"
    protocol_type                = "HTTP"
}

resource "aws_apigatewayv2_stage" "lambda_webhook" {
  api_id      = aws_apigatewayv2_api.lambda_webhook.id
  name        = "sandbox"
  auto_deploy = true
}
