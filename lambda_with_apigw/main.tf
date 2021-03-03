module "lambda_with_hook" {
  source = "./modules/lambda"

  account_id = data.aws_caller_identity.self.account_id
  func_name  = "lambda_hook"
  timeout    = "30"

  lambda_webhook = "${module.api_gateway.execution_arn}/*/*/lambda_hook"

  lambda_env = {
    STAGE = "poc"
  }
}

module "api_gateway" {
  source = "./modules/api_gateway"

  gw_name       = "lambda_hook"
  protocol      = "HTTP"
  role          = "poc"
  target_lambda = module.lambda_with_hook.func_uri
}

output "execute_url" {
  value = module.api_gateway.execution_url
}
