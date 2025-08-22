variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

# the team responsible for maintaining the environment
variable "team" {}

# the environment name ie. flex or prod
variable "environment" {}

# the name of the project
variable "project" {}

# These are the private subnet cidrs
variable "private_subnet_cidr_list" {
  type    = list(string)
  default = ["10.0.56.0/21", "10.0.64.0/21", "10.0.72.0/21"]
}

# These are the public subnet cidrs
variable "public_subnet_cidr_list" {
  type    = list(string)
  default = ["10.0.80.0/21", "10.0.88.0/21", "10.0.96.0/21"]
}

variable "vpc_peering_cidr_list" {
  type    = list(string)
  default = []
}

/*
Primary Fully qualified domain name configured for the environment
e.g.
{
  "fqdn"    : "qdp.com",
  "zone_id" : "xyzuejdjejd",
  "records" : [
    {
      "type" : "MX",
      "hostname" : "qdp.com",
      "values" : [
        "1 smtp.google.com",
        "15 6vmvoyyicaybjd3zvacryagonuay6xq3eaovsytxhwebiqxzse7a.mx-verification.google.com."
      ],
      "ttl" : "300"
    }
  ]
}
*/
variable "fqdns" {
  description = "The FQDN for the domains to configure"
  type        = list(object({
    fqdn    = string,
    zone_id = string,
    records = list(object({
      type = string, hostname = string, values = list(string), ttl = string
    }))
  }))
}

variable "tenants" {
  type = list(
    object({
      name    = string,
      email   = string,
      fqdn    = string,
      #      fqdn_zone_id = string,
      records = list(object({
        type = string, hostname = string, values = list(string), ttl = string
      }))
    }))
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
  tenant_map = {for tenant in var.tenants : tenant.name => tenant}
}
