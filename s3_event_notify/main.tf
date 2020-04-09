locals {
  slack_webhook = "https://hooks.slack.com/services/hoge/fuga/hogefuga"
}

module "lambda_basic" {
  source = "./modules/lambda"

  account_id = data.aws_caller_identity.self.account_id
  func_name  = var.lambda_name

  s3_bucket  = module.cloudfront_basic.s3_bucket

  lambda_env = {
    SLACK_WEBHOOK_URL = local.slack_webhook
    SLACK_CHANNEL     = "hogehoge"
    COLOR             = "danger"
  }
}

module "sns_basic" {
  source = "./modules/sns"

  account_id = data.aws_caller_identity.self.account_id
  s3_bucket  = "module.front.aws_s3_bucket.default.id"
  sns_topic  = "notify_lambda"
}

module "acm_sandbox_domain" {
  source = "./modules/acm"

  providers = {
    aws = aws.us-east-1
  }

  domain_name = var.delegate_domain
  r53_zone_id = var.delegate_domain_id
}

module "cloudfront_basic" {
  source = "./modules/cloudfront"

  delegate_domain = "hogehoge.com"
  zone_id         = "hogehoge"
  bucket_name     = "origin-bucket"

  acm_arn         = module.acm_sandbox_domain.acm_cert_arn
  func_arn        = module.lambda_basic.func_arn
  func_name       = var.lambda_name
  assume_lambda   = module.lambda_basic.lambda_permission
}
