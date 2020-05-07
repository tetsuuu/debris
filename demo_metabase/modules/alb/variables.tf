variable "service_name" {
  type = string
}

variable "default_vpc" {
  type = string
}

variable "lb_sg" {
  type = list(string)
}

variable "lb_is_internal" {
  type    = bool
  default = false
}

variable "lb_subnets" {
  type = list(string)
}

variable "cert_arn" {
  type = string
}
