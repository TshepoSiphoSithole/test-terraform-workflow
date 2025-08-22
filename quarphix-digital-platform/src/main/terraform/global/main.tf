# create s3 logging bucket
module "platform_provision_s3_logging_bucket" {
  source      = "../modules/logging_s3_bucket"
  bucket_name = "qdp-infrastructure-s3-logging"
  environment = "global"
  team        = var.team
  project     = var.project
}

# create terraform state bucket
module "platform_provisioning_state_bucket" {
  source         = "../modules/no_destroy_private_s3_bucket"
  bucket_name    = "qdp-infrastructure-terraform-state"
  logging_bucket = module.platform_provision_s3_logging_bucket.bucket_name
  environment    = "global"
  team           = var.team
  project        = var.project
}

data "aws_organizations_organization" "quarphix" {}


# create tech organisation unit in the parent organisation
resource "aws_organizations_organizational_unit" "tech_department" {
  name      = "TechDepartment"
  parent_id = data.aws_organizations_organization.quarphix.roots[0].id
  tags = merge(local.compulsory_tags, {
    Name = "${var.project}-${var.environment}-ou-TechDepartment"
  })
}

# Create digital platform aws account
resource "aws_organizations_account" "digital_platform" {
  name      = "DigitalPlatform"
  email     = "qx_aws_digital_platform_admins@quarphix.co.za"
  role_name = local.org_access_role_name
  parent_id = aws_organizations_organizational_unit.tech_department.id

  # There is no AWS Organizations API for reading role_name
  lifecycle {
    ignore_changes = [role_name]
  }
}
