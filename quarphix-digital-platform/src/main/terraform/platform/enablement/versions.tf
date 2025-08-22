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

provider "aws" {
  region = "eu-west-1"
  alias  = "digital_platform"
  assume_role {
    role_arn = "arn:aws:iam::621199732982:role/OrganizationAccountAccessRole"
  }
}
