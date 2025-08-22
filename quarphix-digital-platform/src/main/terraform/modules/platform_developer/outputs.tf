output "encrypted_passwords" {
  value = {
    for key, value in aws_iam_user_login_profile.platform_developer_login_profile : key => value.encrypted_password
  }
}

output "platform_developer_arns" {
  value = [for user in aws_iam_user.platform_developer_users : user.arn]
}

output "platform_developers" {
  value = [for user in aws_iam_user.platform_developer_users : user]
}