variable "team" {
  description = "The name of the team responsible for this cluster"
  type        = string
}

variable "environment" {
  description = "The environment in which this cluster is configured"
  type        = string
}

variable "project" {
  description = "The name of the project associated with this cluster"
  type        = string
}

variable "cluster_name" {
  description = "The name of the cluster"
  type        = string
}

variable "vpc_id" {
  description = "The Id of the VPC in which the Cluster is running"
  type        = string
}

variable "alb_security_group_id" {
  description = "The id of the Application Load Balancer Security Group"
  type        = string
}

locals {
  compulsory_tags = {
    Name        = "${var.team}-${var.environment}-${var.project}"
    Team        = var.team
    Project     = var.project
    Environment = var.environment
    Automation  = "terraform"
  }
}
