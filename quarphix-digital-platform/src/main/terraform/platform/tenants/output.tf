output "tenants" {
  value = [
    for tenant in local.tenants : {
      name      = tenant.name
      ecr_repos = module.qdp_container-images-arm64v8[tenant.name].repo_urls
      github_repo = {
        id            = github_repository.tenant_repository[tenant.name].id
        git_clone_url = github_repository.tenant_repository[tenant.name].git_clone_url
        homepage_url  = github_repository.tenant_repository[tenant.name].homepage_url
      }
    }
  ]
}
