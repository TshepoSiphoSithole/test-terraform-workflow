# the team responsible for maintaining the environment
variable "team" {}

# the environment name ie. flex or prod
variable "environment" {}

# the name of the project
variable "project" {}

variable "tenant" {
  type = object({
    name                = string,
    email               = string,
    ecr_repositories = list(string)
  })
}

variable "aws_principals" {
  type    = list(string)
  default = []
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
