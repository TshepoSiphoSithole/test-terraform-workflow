variable "bucket_name" {
  description = "The S3 Bucket name"
}

variable "environment" {
  default = "undefined"
}

variable "team" {
  default = "undefined"
}

variable "project" {
  default = "undefined"
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
