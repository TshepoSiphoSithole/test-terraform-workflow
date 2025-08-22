terraform {
  required_providers {
    aws = {
      source  = "aws"
      version = "~>4.63.0"
      #      configuration_aliases = [aws.organisation]
    }
  }
}