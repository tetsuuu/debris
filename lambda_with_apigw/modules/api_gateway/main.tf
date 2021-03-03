resource "aws_apigatewayv2_api" "lambda_webhook" {
  name          = var.gw_name
  description   = "Endpoint for Lambda"
  protocol_type = var.protocol
}

resource "aws_apigatewayv2_stage" "lambda_webhook" {
  api_id      = aws_apigatewayv2_api.lambda_webhook.id
  name        = var.role
  auto_deploy = true
}

resource "aws_apigatewayv2_route" "lambda_webhook" {
  api_id    = aws_apigatewayv2_api.lambda_webhook.id
  route_key = "ANY /${var.gw_name}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_webhook.id}"
}

resource "aws_apigatewayv2_integration" "lambda_webhook" {
  api_id               = aws_apigatewayv2_api.lambda_webhook.id
  description          = "API Gateway for ${var.gw_name} socket"
  connection_type      = "INTERNET"
  integration_method   = "POST"
  integration_type     = "AWS_PROXY"
  integration_uri      = var.target_lambda
  timeout_milliseconds = 30000
}
