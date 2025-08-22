terraform {
  backend "s3" {
    bucket = "qdp-infrastructure-terraform-state"
    key    = "terraform/platform/tenants"
    region = "eu-west-1"
  }
}
