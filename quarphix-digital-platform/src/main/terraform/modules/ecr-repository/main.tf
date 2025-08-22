data "aws_caller_identity" "current" {}

locals {
  aws_principals = [for o in concat([data.aws_caller_identity.current.account_id], var.aws_principals) : o]
  pull_only_aws_principals = [
    for o in concat([data.aws_caller_identity.current.account_id], var.pull_only_aws_principals) : o
  ]
}

resource "aws_ecr_repository" "ecr_repo" {
  name                 = var.repo_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(local.compulsory_tags, {
    Name : "${var.repo_name}-${var.project}"
  })

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_ecr_repository_policy" "ecr_repo_policy" {
  repository = aws_ecr_repository.ecr_repo.name
  depends_on = [aws_ecr_repository.ecr_repo]
  policy = jsonencode({
    Version = "2008-10-17",
    Statement = [
      {
        Sid    = "Access to ECR Repository",
        Effect = "Allow",
        Principal = {
          "AWS" = local.aws_principals
        },
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:DescribeRepositories",
          "ecr:GetRepositoryPolicy",
          "ecr:ListImages",
          "ecr:DeleteRepository",
          "ecr:BatchDeleteImage",
          "ecr:SetRepositoryPolicy",
          "ecr:DeleteRepositoryPolicy"
        ]
      },
      {
        Sid       = "Pull Access to ECR Repository",
        Effect    = "Allow",
        Principal = {
          "AWS" = local.pull_only_aws_principals
        },
        Action = [
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DescribeImages",
          "ecr:BatchGetImage",
          "ecr:GetLifecyclePolicy",
          "ecr:GetLifecyclePolicyPreview",
          "ecr:ListTagsForResource",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetAuthorizationToken"
        ]
      }
    ]
  })
}

# 
# lifecycle policy on untagged images
# 
resource "aws_ecr_lifecycle_policy" "ecr-lifecycle-policy" {
  repository = aws_ecr_repository.ecr_repo.name
  depends_on = [aws_ecr_repository.ecr_repo]
  policy     = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Expire images older than 1 days",
            "selection": {
                "tagStatus": "untagged",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 1
            },
            "action": {
                "type": "expire"
            }
        },
        {
            "rulePriority": 2,
            "description": "Keep last 3 images",
            "selection": {
                "tagStatus": "tagged",
                "tagPrefixList": ["v"],
                "countType": "imageCountMoreThan",
                "countNumber": 2
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}
