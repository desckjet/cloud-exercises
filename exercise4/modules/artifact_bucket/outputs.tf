output "bucket_name" {
  description = "Name of the artifact S3 bucket."
  value       = aws_s3_bucket.artifacts.bucket
}

output "bucket_arn" {
  description = "ARN of the artifact S3 bucket."
  value       = aws_s3_bucket.artifacts.arn
}
