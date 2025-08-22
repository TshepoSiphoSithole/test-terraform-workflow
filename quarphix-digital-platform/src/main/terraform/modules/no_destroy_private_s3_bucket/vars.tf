variable "bucket_name" {
  description = "The name of the S3 bucket"
}

variable "environment" {
  type = string
  default = "undefined"
}

variable "team" {
  type = string
  default = "undefined"
}

variable "project" {
  type = string
  default = "undefined"
}

variable "logging_bucket" {
  type = string
}

locals {
  compulsory_tags = {
    Name        = "${var.team}-${var.environment}-${var.project}-${var.bucket_name}"
    Team        = var.team
    Project     = var.project
    Environment = var.environment
    Automation  = "terraform"
  }
}
