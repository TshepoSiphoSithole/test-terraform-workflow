output "tenant" {
  value = var.tenant
}

output "ecr_repository" {
  value = {
    id   = module.qdp_container-images-amd64.registry_id
    arns = module.qdp_container-images-amd64.repository_arns
    url  = module.qdp_container-images-amd64.repository_url
  }
}

output "github_tenant_repo" {
  value = {
    id            = github_repository.tenant_repository.id
    git_clone_url = github_repository.tenant_repository.git_clone_url
    homepage_url  = github_repository.tenant_repository.homepage_url
  }
}