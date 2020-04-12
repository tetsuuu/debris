provider "aws" {
  region  = "ap-northeast-1"
  version = "~> 2.50.0"
}

data "aws_caller_identity" "self" {}
