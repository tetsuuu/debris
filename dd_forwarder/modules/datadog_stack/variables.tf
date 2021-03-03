variable "role" {
  type = string
}

variable "api_key" {
  type = string
}

variable "dd_version" {
  type = string
}

variable "s3_bucket" {
  type = string
}

variable "bucket_prefix" {
  type = list(string)
}

variable "logging_bucket" {
  type = string
}

variable "log_prefix" {
  type = string
}
