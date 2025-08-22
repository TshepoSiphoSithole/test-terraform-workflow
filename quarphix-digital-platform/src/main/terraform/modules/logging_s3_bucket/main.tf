resource "aws_s3_bucket" "log_bucket" {
  bucket = var.bucket_name
  tags   = merge(local.compulsory_tags, {
    Name = "${var.team}-${var.environment}-${var.project}-${var.bucket_name}"
  })
}

resource "aws_s3_bucket_ownership_controls" "log_bucket" {
  bucket = aws_s3_bucket.log_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "log_bucket_acl" {
  bucket = aws_s3_bucket.log_bucket.id
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket_logging" "log_bucket" {
  bucket        = aws_s3_bucket.log_bucket.id
  target_bucket = aws_s3_bucket.log_bucket.id
  target_prefix = "log/"
}