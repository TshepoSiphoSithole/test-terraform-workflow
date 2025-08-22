output "repo_urls" {
  value = [for repo in var.tenant.ecr_repositories : module.qdp_container-images-arm64v8[repo].repository_url]
}