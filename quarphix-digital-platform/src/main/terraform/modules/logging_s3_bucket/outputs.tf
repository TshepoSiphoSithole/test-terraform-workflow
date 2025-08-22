output "bucket_regional_domain_name" {
  value = aws_s3_bucket.log_bucket.bucket_regional_domain_name
}

output "bucket_arn" {
  value = aws_s3_bucket.log_bucket.arn
}

output "bucket_name" {
  value = aws_s3_bucket.log_bucket.id
}
