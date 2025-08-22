# tenant registration without provisioning
data "aws_caller_identity" "current" {}


module "qdp_container-images-deploy-tools" {
  source                   = "../../modules/ecr-repository"
  repo_name                = "qdp-container-images/amd64/qdp-deploy-tools"
  environment              = var.environment
  team                     = var.team
  project                  = var.project
  aws_principals           = [data.aws_caller_identity.current.arn]
  pull_only_aws_principals = data.terraform_remote_state.global_state.outputs.platform_developer_arns
  providers = {
    aws = aws.digital_platform
  }
}

module "qdp_container-images-arm64v8" {
  for_each                 = toset(var.arm64v8_repos)
  source                   = "../../modules/ecr-repository"
  repo_name                = "qdp-container-images/arm64v8/${each.value}"
  environment              = var.environment
  team                     = var.team
  project                  = var.project
  aws_principals           = [data.aws_caller_identity.current.arn]
  pull_only_aws_principals = data.terraform_remote_state.global_state.outputs.platform_developer_arns
  providers = {
    aws = aws.digital_platform
  }
}
