provider "aws" {
  region  = "ap-northeast-1"
  version = "~> 2.67.0"
}

data "aws_caller_identity" "self" {}
