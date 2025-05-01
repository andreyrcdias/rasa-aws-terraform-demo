provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.81.0"
    }
    # TODO
    # docker = {
    #   source  = "kreuzwerker/docker"
    #   version = "3.0.2"
    # }
  }
}
