variable "repo_name" {
  type        = string
  description = "The repository to create"
}

variable "team" {
  description = "Team"
}

variable "environment" {
  description = "Environment"
}

variable "project" {
  description = "Project"
}

variable "aws_principals" {
  description = "List of AWS Principals that will be given access to the ecr repository"
  default     = []
}

variable "pull_only_aws_principals" {
  description = "List of AWS Principals that pull be given pull only access to the ecr repository"
  default     = []
}

locals {
  compulsory_tags = {
    Name        = "${var.team}-${var.project}"
    Team        = var.team
    Project     = var.project
    Environment = var.environment
    Automation  = "terraform"
  }
}
