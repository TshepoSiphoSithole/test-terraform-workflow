#
# provision the flex environment.
#
module "flex_environment" {
  source      = "../../../modules/platform_environment"
  environment = var.environment
  project     = var.project
  team        = var.team
  fqdns = [
    {
      fqdn    = "quarphix-digital.net",
      zone_id = "Z10263801TM1XCEDU8YKH",
      records = []
    }
  ]
  providers = {
    aws = aws.digital_platform
  }
  tenants = local.tenants
}
