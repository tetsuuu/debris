variable "aws_account_id" {
  type    = string
  default = 012345678901
}

variable "enable_cwlogs" {
  type    = bool
  default = false
}

variable "function_name" {
  type = string
}

variable "lambda_runtime" {
  type = string
}

variable "lambda_handler" {
  type = string
}

variable "lambda_source" {
  type = string
}

variable "lambda_hash" {
  type = string
}

variable "lambda_envs" {
  type = map(string)
}

variable "lambda_timeout" {
  type    = string
  default = 60 * 5
}

variable "sns_topic_name" {
  type = string
}

variable "layer_arns" {
  type    = list(string)
  default = null
}