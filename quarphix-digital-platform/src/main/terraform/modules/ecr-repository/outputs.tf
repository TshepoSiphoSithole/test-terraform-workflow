output "repository_url" {
  value = aws_ecr_repository.ecr_repo.repository_url
}

output "repository_arns" {
  value = aws_ecr_repository.ecr_repo.arn
}

output "registry_id" {
  value = aws_ecr_repository.ecr_repo.registry_id
}

output "aws_principals" {
  value = local.aws_principals
}