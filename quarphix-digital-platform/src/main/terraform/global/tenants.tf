# tenant registration without provisioning
locals {
  tenant_map = { for tenant in var.tenants : tenant.name => tenant }
}
# create organisation unit to create the tenants
resource "aws_organizations_organizational_unit" "platform_tenants" {
  name      = "PlatformTenants"
  parent_id = aws_organizations_organizational_unit.tech_department.id
  tags = merge(local.compulsory_tags, {
    Name = "${var.project}-${var.environment}-ou-PlatformTenants"
  })
}


# register tenant organisation accounts
resource "aws_organizations_account" "tenant" {
  for_each          = local.tenant_map
  name              = each.value.name
  email             = each.value.email
  parent_id         = aws_organizations_organizational_unit.platform_tenants.id
  role_name         = local.org_access_role_name
  close_on_deletion = true
}
