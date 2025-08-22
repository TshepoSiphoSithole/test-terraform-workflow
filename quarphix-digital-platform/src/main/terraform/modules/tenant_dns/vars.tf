# the team responsible for maintaining the environment
variable "team" {}

# the environment name ie. flex or prod
variable "environment" {}

# the name of the project
variable "project" {}

variable "tenant" {
  type = object({
    name = string
  })
}

variable "fqdn_suffixes" {
  description = "Fully qualified domain name suffixes"
  type        = list(object({
    fqdn    = string
    zone_id = string
  }))
}

variable "aws_principals" {
  type    = list(string)
  default = []
}

variable "vpc_id" {
  type = string
}

variable "load_balancer" {
  type = object({
    arn         = string
    dns_name    = string
    zone_id     = string
    lb_listener = object({
      arn = string
    })
    target_group = object({
      arn = string
    })
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

  fqdn_zone_id_map = {
    for fqdn in var.fqdn_suffixes : "${lower(var.tenant.name)}.${fqdn.fqdn}"=> fqdn.zone_id
  }
}
