provider "aws" {
  region  = "ap-northeast-1"
  version = "~> 2.50.0"
}

provider "aws" {
  alias   = "us-east-1"
  region  = "us-east-1"
  version = "~> 2.50.0"
}

data "aws_caller_identity" "self" {}

provider "sops" {
}
