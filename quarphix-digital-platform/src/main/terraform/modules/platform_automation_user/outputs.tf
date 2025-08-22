
output "automation_users_arns" {
  value = [for user in aws_iam_user.automation_users : user.arn]
}

output "automation_users" {
  value = [for user in aws_iam_user.automation_users : user]
}