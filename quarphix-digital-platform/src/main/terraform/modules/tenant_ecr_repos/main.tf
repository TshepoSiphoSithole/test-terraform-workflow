module "qdp_container-images-arm64v8" {
  for_each = toset(var.tenant.ecr_repositories)
  source         = "../ecr-repository"
  repo_name      = "qdp-container-images/arm64v8/${lower(var.tenant.name)}/${each.value}"
  environment    = var.environment
  team           = var.team
  project        = var.project
  aws_principals = var.aws_principals
}
