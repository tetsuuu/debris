provider "aws" {
  region  = "ap-northeast-1"
  version = "2.51.0"
}

provider "template" {
  version = "2.1.2"
}

data "aws_caller_identity" "self" {}
