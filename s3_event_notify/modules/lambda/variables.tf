variable "account_id" {
  type = string
}

variable "func_name" {
  type = string
}

variable "lambda_env" {
  type = map(string)
}

variable "s3_bucket" {
  type = string
}