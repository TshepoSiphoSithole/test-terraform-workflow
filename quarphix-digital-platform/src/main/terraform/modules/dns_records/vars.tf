variable "team" {
  description = "Team"
}

variable "environment" {
  description = "Environment"
}

variable "project" {
  description = "Project"
}

variable "zone_id" {
  description = "The Id of the Zone created during registration"
}

variable "fqdn_suffix" {
  description = "The FQDN for each domain records and certificate validation will be created"
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

variable "fqdn_records" {
  description = "Other DNS records for the domain name to create"
  default     = []
  type        = list(object({ type = string, hostname = string, values = list(string), ttl = string }))
}