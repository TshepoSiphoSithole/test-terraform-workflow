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