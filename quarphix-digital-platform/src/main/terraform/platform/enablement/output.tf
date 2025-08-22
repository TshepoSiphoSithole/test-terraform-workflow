output "qdp_container-images-arm64v8_repo" {
  value = [for repo in var.arm64v8_repos : module.qdp_container-images-arm64v8[repo].repository_url]
}

output "qdp_container-images-deploy-tools_repo" {
  value = module.qdp_container-images-deploy-tools.repository_url
}
