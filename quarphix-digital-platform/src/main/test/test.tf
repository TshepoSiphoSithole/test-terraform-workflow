terraform {
  required_providers {
    aws = {
      source  = "aws"
      version = "~>4.63.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

data "aws_organizations_organization" "example" {}

#data "aws_organizations_organizational_unit" "ou" {
#  parent_id = data.aws_organizations_organization.example.roots[0].id
#  name      = "dev"
#}

data "aws_organizations_organizational_units" "ou" {
  parent_id = data.aws_organizations_organization.example.id
}

output "account_ids" {
  value = data.aws_organizations_organization.example.id
}

output "org" {
  value = data.aws_organizations_organization.example
}

output "org_units" {
  value = data.aws_organizations_organizational_units.ou
}