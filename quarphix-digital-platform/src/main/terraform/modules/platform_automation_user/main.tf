resource "aws_iam_policy" "platform_automation_user_policy" {
  name        = var.policy_name
  path        = "/"
  description = "Policy that governs the Platform Automation User"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowSpecifics",
      "Action": [
        "lambda:*",
        "apigateway:*",
        "ec2:*",
        "rds:*",
        "s3:*",
        "sns:*",
        "states:*",
        "ssm:*",
        "sqs:*",
        "iam:*",
        "elasticloadbalancing:*",
        "autoscaling:*",
        "cloudwatch:*",
        "cloudfront:*",
        "route53:*",
        "ecr:*",
        "logs:*",
        "ecs:*",
        "application-autoscaling:*",
        "logs:*",
        "events:*",
        "elasticache:*",
        "es:*",
        "kms:*",
        "dynamodb:*",
        "organizations:*",
        "codeartifact:*",
        "sts:GetServiceBearerToken",
        "eks:*",
        "acm:*",
        "ses:*",
        "servicediscovery:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Sid": "DenySpecifics",
      "Action": [
        "account:GetAccountInformation",
        "budgets:*",
        "config:*",
        "directconnect:*",
        "aws-marketplace:*",
        "aws-marketplace-management:*",
        "ec2:*ReservedInstances*"
      ],
      "Effect": "Deny",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_group" "platform_automation_group" {
  name = "platform_automation_group"
}

resource "aws_iam_user" "automation_users" {
  for_each = toset(var.user_names)
  name     = each.key
  path     = "/"

  tags = merge(local.compulsory_tags, {
    Name = "${var.team}-${var.environment}-${var.project}-${each.key}"
  })
}

resource "aws_iam_group_membership" "automation_team" {
  name = "automation-team-group-membership"

  users = var.user_names
  group = aws_iam_group.platform_automation_group.name
}

resource "aws_iam_policy_attachment" "platform-policy-attach" {
  name       = "platform-policy-attachment"
  groups     = [aws_iam_group.platform_automation_group.name]
  policy_arn = aws_iam_policy.platform_automation_user_policy.arn
}


resource "aws_iam_policy" "assume_org_role_policy" {
  count       = length(var.member_accounts) >= 1 ? 1 : 0
  name        = "MemberAccountAssumeRolePolicy"
  path        = "/"
  description = "Policy that governs the Platform Automation User Assumption of the Admin Role for member accounts"
  policy      = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow"
        Action   = "sts:AssumeRole"
        Resource = local.org_access_roles
      }
    ]
  })

  tags = merge(local.compulsory_tags, {
    Name = "${var.project}-MemberAccountAssumeRolePolicy"
  })
}

resource "aws_iam_policy_attachment" "platform-policy-attach-org-access" {
  count      = length(var.member_accounts) >= 1 ? 1 : 0
  name       = "platform-policy-attachment-org-access"
  groups     = [aws_iam_group.platform_automation_group.name]
  policy_arn = aws_iam_policy.assume_org_role_policy[0].arn
}