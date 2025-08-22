resource "aws_iam_policy" "platform_developer_policy" {
  name        = var.policy_name
  path        = "/"
  description = "Policy that governs the Platform Developer Users"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "MultiFactorPermissions",
      "Effect": "Allow",
      "Action": [
        "iam:EnableMFADevice",
        "iam:CreateVirtualMFADevice",
        "iam:ListMFADevices",
        "iam:ListVirtualMFADevices",
        "iam:ChangePassword"
      ],
      "Condition": {
        "Bool": {
          "aws:MultiFactorAuthPresent": "false"
        }
      },
      "Resource": "*"
    },
    {
      "Sid": "MultiFactor",
      "Effect": "Allow",
      "Action": [
        "iam:*Login*",
        "iam:List*",
        "iam:Get*",
        "iam:CreateAccessKey",
        "iam:DeleteAccessKey",
        "iam:UpdateAccessKey",
        "iam:ChangePassword"
      ],
      "Condition": {
        "Bool": {
          "aws:MultiFactorAuthPresent": "true"
        }
      },
      "Resource": "*"
    },
    {
      "Sid": "AllowSpecifics",
      "Action": [
        "ses:SendRawEmail",
        "sns:Publish",
        "sqs:SendMessage",
        "sqs:GetQueueAttributes",
        "sqs:GetQueueUrl",
        "sqs:ListDeadLetterSourceQueues",
        "sqs:ListQueues",
        "sqs:ListQueueTags",
        "sqs:ReceiveMessage",
        "sqs:ChangeMessageVisibility",
        "sqs:DeleteMessage",
        "account:GetAccountInformation",
        "rds:*",
        "s3:*",
        "cloudwatch:*",
        "route53:*",
        "ecr:*",
        "logs:*",
        "ecs:*",
        "sts:GetServiceBearerToken",
        "sts:AssumeRole",
        "eks:*",
        "codeartifact:*",
        "secretsmanager:CreateSecret",
        "secretsmanager:GetSecretValue",
        "secretsmanager:UpdateSecret",
        "secretsmanager:TagResource",
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:GenerateDataKey",
        "kms:DescribeKey"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Sid": "DenySpecifics",
      "Action": [
        "iam:*Provider*",
        "budgets:*",
        "config:*",
        "directconnect:*",
        "aws-marketplace:*",
        "aws-marketplace-management:*",
        "ec2:*ReservedInstances*",
        "lambda:*",
        "apigateway:*",
        "ec2:*",
        "states:*",
        "ssm:*",
        "elasticloadbalancing:*",
        "autoscaling:*",
        "cloudfront:*",
        "application-autoscaling:*",
        "events:*",
        "elasticache:*",
        "es:*",
        "dynamodb:*",
        "organizations:*",
        "acm:*"
      ],
      "Effect": "Deny",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_group" "platform_developer_group" {
  name = "platform_developer_user_group"
}

resource "aws_iam_user" "platform_developer_users" {
  for_each = tomap(var.user_to_keybase_user_map)
  name     = each.key
  path     = "/"

  tags = merge(local.compulsory_tags, {
    Name = "${var.team}-${var.environment}-${var.project}-${each.key}"
  })
}

resource "aws_iam_user_login_profile" "platform_developer_login_profile" {
  for_each   = tomap(var.user_to_keybase_user_map)
  user       = each.key
  pgp_key    = "keybase:${each.value}"
  depends_on = [aws_iam_user.platform_developer_users]
}

resource "aws_iam_group_membership" "platform_developer_users_team" {
  name = "platform-developer-team-group-membership"

  users      = keys(var.user_to_keybase_user_map)
  group      = aws_iam_group.platform_developer_group.name
  depends_on = [aws_iam_user.platform_developer_users]
}

resource "aws_iam_policy_attachment" "platform-developer-user-policy-attach" {
  name       = "platform-developer-terraform-policy-attachment"
  groups     = [aws_iam_group.platform_developer_group.name]
  policy_arn = aws_iam_policy.platform_developer_policy.arn
}

# assign assume role permissions.

resource "aws_iam_policy" "assume_org_role_policy" {
  count       = length(var.member_accounts) >= 1 ? 1 : 0
  name        = "PlatformDeveloperTenantAccountAssumeRolePolicy"
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
  groups     = [aws_iam_group.platform_developer_group.name]
  policy_arn = aws_iam_policy.assume_org_role_policy[0].arn
}