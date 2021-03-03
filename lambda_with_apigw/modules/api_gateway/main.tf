resource "aws_apigatewayv2_api" "lambda_webhook" {
  name          = var.gw_name
  description   = "Post URL for AWS Lambda"
  protocol_type = var.protocol
}

resource "aws_apigatewayv2_stage" "lambda_webhook" {
  api_id      = aws_apigatewayv2_api.lambda_webhook.id
  name        = var.role
  auto_deploy = true
}
