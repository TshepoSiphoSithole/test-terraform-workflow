variable "team" {
  default = "platform"
}

variable "environment" {
  default = "flex"
}

variable "project" {
  default = "QDP"
}


variable "github_token" {
  type = string
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
  tenants = data.terraform_remote_state.global_state.outputs.tenants
  tenant_map = {
    for tenant in data.terraform_remote_state.global_state.outputs.tenants : tenant.name => tenant
  }
  tenant_github_maintainers = {
    for tenant in data.terraform_remote_state.global_state.outputs.tenants : tenant.name => tenant.github_maintainers
  }
  tenant_github_members = {
    for tenant in data.terraform_remote_state.global_state.outputs.tenants : tenant.name => tenant.github_members
  }
}
