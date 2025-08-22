terraform {
  backend "s3" {
    bucket = "qdp-infrastructure-terraform-state"
    key    = "terraform/environment/prod"
    region = "eu-west-1"
  }
}
