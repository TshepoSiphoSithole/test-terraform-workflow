output "developer_passwords" {
  value = module.platform_developers.encrypted_passwords
}

output "platform_developer_arns" {
  value = module.platform_developers.platform_developer_arns
}

output "platform_developers" {
  value = module.platform_developers.platform_developers
}

output "automation_users_arns" {
  value = module.platform_automation_users.automation_users_arns
}

output "automation_users" {
  value = module.platform_automation_users.automation_users
}

output "tenants" {
  value = [
    for tenant in var.tenants : {
      name                = tenant.name
      email               = tenant.email
      fqdn                = tenant.fqdn
      records             = tenant.records
      account_id          = aws_organizations_account.tenant[tenant.name].id,
      github_maintainers  = tenant.github_maintainers,
      github_members      = tenant.github_members,
      github_repositories = tenant.github_repositories,
      ecr_repositories    = tenant.ecr_repositories
    }
  ]
}