module "datadog_forwarder" {
  source = "./modules/datadog_stack"

  api_key   = "fizzbuzzfizzbuzz"
  role      = "dev"
  s3_bucket = "buzz.dev.bucket"

  filter_pattern = "php"

  bucket_prefix = [
    "fizz/",
    "buzz/",
  ]
}