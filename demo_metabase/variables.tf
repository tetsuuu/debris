variable "delegate_domain_id" {
  default = "ZX1234abcd56"
}

variable "delegate_domain" {
  default = "hogehoge.com"
}

variable "service_name" {
  default = "metabase"
}

variable "service_vpc" {
  default = "vpc-123456abcdef9"
}

variable "public_subnet" {
  default = [
    "subnet-0123456abcdefg890",
    "subnet-abcdefg0123456789",
    "subnet-789abcdefgh012345",
  ]
}

variable "private_subnet" {
  default = [
    "subnet-01234abcdefghi890",
    "subnet-hijklmn0123456opq",
    "subnet-56789zxwvyqop0123",
  ]
}

