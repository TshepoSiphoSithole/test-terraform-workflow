# the team responsible for maintaining the environment
variable "team" {}

# the environment name ie. flex or prod
variable "environment" {}

# the name of the project
variable "project" {}

variable "vpc_id" {
  description = "The Id of the VPC in which the Cluster is running"
  type        = string
}

variable "alb_security_group_id" {
  description = "The id of the Application Load Balancer Security Group"
  type        = string
}


variable "tenant" {
  type = object({
    name  = string
    email = string
  })
}


locals {
  compulsory_tags = {
    Name        = "${var.project}-${var.environment}"
    Team        = var.team
    Project     = var.project
    Environment = var.environment
    Automation  = "terraform"
  }
}
