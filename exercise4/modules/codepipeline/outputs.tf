output "pipeline_name" {
  description = "CodePipeline name."
  value       = aws_codepipeline.pipeline.name
}

output "pipeline_arn" {
  description = "CodePipeline ARN."
  value       = aws_codepipeline.pipeline.arn
}

output "service_role_arn" {
  description = "IAM role ARN used by CodePipeline."
  value       = aws_iam_role.codepipeline.arn
}
