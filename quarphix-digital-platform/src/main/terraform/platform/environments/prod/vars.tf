variable "team" {
  default = "platform"
}

variable "environment" {
  default = "prod"
}

variable "project" {
  default = "QDP"
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
  tenants    = data.terraform_remote_state.global_state.outputs.tenants
  tenant_map = { for tenant in data.terraform_remote_state.global_state.outputs.tenants : tenant.name => tenant }
  compulsory_tags = {
    Name        = "${var.team}-${var.environment}-${var.project}"
    Team        = var.team
    Project     = var.project
    Environment = var.environment
    Automation  = "terraform"
  }
}
