variable "service_name" {
  default = {
    hogehoge = "hoge-cluster"
    fugafuga = "hoge-cluster"
  }
}

variable "sns_topic_arns" {
  default = []
}
