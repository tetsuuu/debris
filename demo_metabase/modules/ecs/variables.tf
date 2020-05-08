variable "vpc_id" {
  type = string
}

variable "ecs_cluster_name" {
  type = string
}

variable "service_name" {
  type = string
}

variable "lb_target" {
  type = string
}

variable "lb_dimension" {
  type = string
}

variable "container_label" {
  type = string
  default = "latest"
}

variable "image_name" {
  type = string
}

variable "container_port" {
  type    = number
  default = 3000
}

variable "ecs_subnets" {
  type = list(string)
}

variable "ecs_sgs" {
  type = list(string)
}

variable "db_type" {
  type    = string
  default = "postgres"
}

variable "db_dbname" {
  type = string
}

variable "db_port" {
  type = string
  default = "5432"
}

variable "db_host" {
  type = string
}

variable "db_user" {
  type = string
}

variable "db_pass" {
  type = string
}
