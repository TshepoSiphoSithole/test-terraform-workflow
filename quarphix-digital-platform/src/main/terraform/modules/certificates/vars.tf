variable "team" {
  description = "Team"
}

variable "environment" {
  description = "Environment"
}

variable "project" {
  description = "Project"
}

variable "fqdn_suffix" {
  description = "The FQDN for each domain records and certificate validation will be created"
  type        = string
}

variable "zone_id" {
  description = "The Route53 ZoneId to use to register certificate entries"
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
