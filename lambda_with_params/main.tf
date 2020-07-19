module "lambda_with_params" {
  source = "./lambda"

  account_id          = data.aws_caller_identity.self.account_id
  cw_event_name       = "hogehoge-execute"
  description         = "fugafuga用スケジュール"
  schedule_expression = "cron(0/30 * * * ? *)"
  func_name           = "lambda_with_params"
  timeout             = "30"
  param_name          = "piyopiyo-secret-key"
  bastion_sg          = [""]
  bastion_subnets     = [""]

  lambda_env = {
    STAGE             = "sandbox"
    SLACK_WEBHOOK_URL = ""
    SLACK_CHANNEL     = ""
    SECRET_KEY_NAME   = "piyopiyo-secret-key"
    BASE_RECORD       = ""
    API_PATH          = ""
  }
}
