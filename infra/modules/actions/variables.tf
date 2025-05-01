variable "project" {
  type    = string
  default = "rasa-aws-terraform-demo"
}

variable "app_name" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "aws_access_key_id" {
  type = string
}

variable "aws_secret_access_key" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnets" {
  type = list(string)
}

variable "core_sg_id" {
  type = string
}

variable "ecs_desired_count" {
  type = number
}

variable "ecs_cluster_id" {
  type = string
}

variable "ecs_task_execution_role_arn" {
  type = string

}

variable "route53_zone_id" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "acm_certificate_arn" {
  type = string
}

