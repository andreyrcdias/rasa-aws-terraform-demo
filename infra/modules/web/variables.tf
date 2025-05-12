variable "project" {
  type    = string
  default = "rasa-aws-terraform-demo"
}

variable "app_name" {
  type = string
}

variable "aws_region" {
  description = "AWS Region"
  default     = "us-east-1"
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
