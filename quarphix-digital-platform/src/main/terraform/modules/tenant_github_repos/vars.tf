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
    github_team_id      = string,
    github_repositories = list(string)
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
