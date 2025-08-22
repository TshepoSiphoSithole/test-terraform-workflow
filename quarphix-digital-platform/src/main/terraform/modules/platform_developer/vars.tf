variable "user_to_keybase_user_map" {
  type        = map(string)
  description = "The Map of usernames to the keybase users to be create in the group"
}

variable "environment" {
  default = "undefined"
}

variable "team" {
  default = "undefined"
}

variable "project" {
  default = "undefined"
}

variable "policy_name" {
  type    = string
  default = "PlatformDeveloperUserPolicy"
}

variable "admin_role" {
  type        = string
  description = "The administrative role to assume in member accounts"
  default     = "OrganizationAccountAccessRole"
}

variable "member_accounts" {
  type        = list(string)
  description = "The list of AWS accounts for which the administrative role is applicable"
  default     = []
}

locals {
  compulsory_tags = {
    Name        = "${var.team}-${var.environment}-${var.project}"
    Team        = var.team
    Project     = var.project
    Environment = var.environment
    Automation  = "terraform"
  }
  org_access_roles = [for k in var.member_accounts : "arn:aws:iam::${k}:role/${var.admin_role}"]
}
