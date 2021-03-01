//module "lambda_with_params" {
//  source = "./lambda"
//
//  account_id          = data.aws_caller_identity.self.account_id
//  func_name           = "lambda_with_webhook"
//  timeout             = "30"
//
//  lambda_webhook = module.api_gateway.execution_arn
//
//  lambda_env = {
//    STAGE             = "sandbox"
//  }
//}
//
//module "api_gateway" {
//  source = "./api_gateway"
//}
