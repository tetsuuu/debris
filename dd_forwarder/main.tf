module "datadog_forwarder" {
  source = "./modules/datadog_stack"

  api_key        = "fizzbuzzfizzbuzz"
  role           = "dev"
  s3_bucket      = "fizz.dev.com"
  dd_version     = "3.28.4"
  logging_bucket = "buzz.dev.com"
  log_prefix     = "fizz"

  bucket_prefix = [
    "fizz/",
    "buzz/",
  ]
}
