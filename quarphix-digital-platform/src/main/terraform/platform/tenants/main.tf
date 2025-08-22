# tenant registration without provisioning

data "aws_caller_identity" "current" {}

module "qdp_container-images-arm64v8" {
  for_each    = local.tenant_map
  source      = "../../modules/tenant_ecr_repos"
  environment = var.environment
  team        = var.team
  project     = var.project
  tenant = {
    name             = each.value.name,
    email            = each.value.email,
    ecr_repositories = each.value.ecr_repositories
  }
  aws_principals = [data.aws_caller_identity.current.arn]
  providers = {
    aws = aws.digital_platform
  }
}

#
# create a github team for the tenant
#
resource "github_team" "tenant_team" {
  for_each    = local.tenant_map
  name        = each.value.name
  description = "The github space for tenant: ${each.value.name}"
  privacy     = "closed"
}

# create a service repository of the tenant
resource "github_repository" "tenant_repository" {
  for_each                    = local.tenant_map
  name                        = "${lower(each.value.name)}-service"
  description                 = "The service repository for the tenant used to define and create resources in the tenant aws account"
  visibility                  = "private"
  has_issues                  = false
  has_discussions             = false
  has_projects                = false
  is_template                 = false
  allow_merge_commit          = false
  allow_squash_merge          = true
  allow_rebase_merge          = true
  squash_merge_commit_title   = "PR_TITLE"
  squash_merge_commit_message = "PR_BODY"
  delete_branch_on_merge      = true
  has_downloads               = false
  allow_update_branch         = true
}

# assign the tenant repository to the team's team
resource "github_team_repository" "tenant_repository" {
  for_each   = local.tenant_map
  repository = github_repository.tenant_repository[each.key].id
  team_id    = github_team.tenant_team[each.key].id
  permission = "maintain"
}

# assign maintainer and member permissions to github users
resource "github_team_members" "maintainers" {
  for_each = local.tenant_map
  team_id  = github_team.tenant_team[each.key].id

  dynamic "members" {
    for_each = toset(local.tenant_github_maintainers[each.key])
    content {
      username = members.value
      role     = "maintainer"
    }
  }

  dynamic "members" {
    for_each = toset(local.tenant_github_members[each.key])
    content {
      username = members.value
      role     = "member"
    }
  }
}

module "tenant_repositories" {
  for_each    = local.tenant_map
  source      = "../../modules/tenant_github_repos"
  environment = var.environment
  project     = var.project
  team        = var.team
  tenant = {
    name                = each.value.name,
    email               = each.value.email,
    github_team_id      = github_team.tenant_team[each.key].id,
    github_repositories = each.value.github_repositories
  }
  providers = {
    github = github
  }
}