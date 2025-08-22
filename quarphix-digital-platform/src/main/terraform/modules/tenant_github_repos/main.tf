resource "github_team_repository" "legacy_repos" {
  for_each   = toset(var.tenant.github_repositories)
  repository = each.value
  team_id    = var.tenant.github_team_id
  permission = "maintain"
}