terraform {
  backend "s3" {
    bucket = "qdp-infrastructure-terraform-state"
    key    = "terraform/environment/flex"
    region = "eu-west-1"
  }
}
