terraform {
  backend "s3" {
    bucket = "qdp-infrastructure-terraform-state"
    key    = "terraform/platform/enablement"
    region = "eu-west-1"
  }
}
