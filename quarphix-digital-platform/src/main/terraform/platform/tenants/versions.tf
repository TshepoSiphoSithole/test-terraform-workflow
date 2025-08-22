terraform {
  required_providers {
    aws = {
      source  = "aws"
      version = "~>4.63.0"
    }
    github = {
      source  = "integrations/github"
      version = "~>5.0"
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

provider "github" {
  token = var.github_token
  owner = "QuarphixCorp"
}
