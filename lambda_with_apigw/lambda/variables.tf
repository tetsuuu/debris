variable "account_id" {
  type = string
}

//variable "param_name" {
//  type = string
//}
//
variable "func_name" {
  type = string
}

variable "timeout" {
  type = string
}

variable "lambda_env" {
  type = map(string)
}

variable "lambda_webhook" {
  type = string
}