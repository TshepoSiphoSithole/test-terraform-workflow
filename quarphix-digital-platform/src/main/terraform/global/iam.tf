# create platform developer IAM user accounts
module "platform_developers" {
  source = "../modules/platform_developer"
  user_to_keybase_user_map = {
    "charles@quarphix.co.za"              = "ctumwebaze",
    "aron.makiika@codeadvanced.co.za"     = "aronmakiika",
    "edgar.kanyesigye@codeadvanced.co.za" = "edgarkanyes",
    "matimu@quarphix.co.za"               = "riecky",
    "sithole@quarphix.co.za"              = "tsheposithole"
  }
  environment = var.environment
  team        = var.team
  project     = var.project
  admin_role  = local.org_access_role_name
  member_accounts = concat([aws_organizations_account.digital_platform.id], [
    for tenant in var.tenants : aws_organizations_account.tenant[tenant.name].id
  ])
  policy_name = "QuarphixPlatformDeveloperUserPolicy"
}

# create automation IAM user account
module "platform_automation_users" {
  source      = "../modules/platform_automation_user"
  user_names  = ["qdp_terraform_cli"]
  environment = var.environment
  team        = var.team
  project     = var.project
  policy_name = "QuarphixPlatformAutomationUserPolicy"
  admin_role  = local.org_access_role_name
  member_accounts = concat([aws_organizations_account.digital_platform.id], [
    for tenant in var.tenants : aws_organizations_account.tenant[tenant.name].id
  ])
}
