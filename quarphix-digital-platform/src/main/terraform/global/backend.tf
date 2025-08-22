terraform {
  backend "s3" {
    bucket = "qdp-infrastructure-terraform-state"
    key    = "terraform/environment/global"
    region = "eu-west-1"
  }
}
