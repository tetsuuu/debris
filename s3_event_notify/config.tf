provider "aws" {
  region  = "ap-northeast-1"
  version = "~> 2.50.0"
}

provider "archive" {
  version = "~> 1.3"
}

provider "aws" {
  alias   = "us-east-1"
  region  = "us-east-1"
  version = "~> 2.50.0"
}

data "aws_caller_identity" "self" {}
