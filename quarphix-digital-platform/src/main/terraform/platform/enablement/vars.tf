variable "team" {
  default = "platform"
}

variable "environment" {
  default = "enablement"
}

variable "project" {
  default = "QDP"
}

variable "arm64v8_repos" {
  type = list(string)
  default = [
    "authorisation-server",
    "jdk17",
    "node18",
    "oidc-relying-party",
    "postgres-db-init",
    "authorisation-server-init",
    "jre17",
    "mysql-db-init"
  ]
}

data "terraform_remote_state" "global_state" {
  backend = "s3"

  config = {
    bucket = "qdp-infrastructure-terraform-state"
    key    = "terraform/environment/global"
    region = "eu-west-1"
  }
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
