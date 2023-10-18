variable "cw_filter_name" {
  type = string
}

variable "cw_log_group_name" {
  type = string
}

variable "cw_filter_pattern" {
  type = string
}

variable "cw_alarm_name" {
  type = string
}

variable "cw_alarm_operator" {
  type = string
}

variable "cw_alarm_statistic" {
  type = string
}

variable "sns_topic_arns" {
  type = list(string)
}

variable "cw_default_metric" {
  type    = string
  default = null
}

variable "cw_filter_namespace" {
  type    = string
  default = "CloudTrailMetrics"
}

variable "cw_alarm_period" {
  type    = number
  default = 300
}

variable "cw_evaluation_periods" {
  type    = number
  default = 1
}

variable "cw_datapoints" {
  type    = number
  default = null
}
