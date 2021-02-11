variable "role" {
  type = string
}

variable "filter_pattern" {
  type    = string
  default = null
}

variable "api_key" {
  type = string
}

variable "s3_bucket" {
  type = string
}

variable "bucket_prefix" {
  type = list(string)
}
