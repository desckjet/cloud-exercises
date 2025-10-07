output "project_name" {
  description = "CodeBuild project name."
  value       = aws_codebuild_project.build.name
}

output "project_arn" {
  description = "CodeBuild project ARN."
  value       = aws_codebuild_project.build.arn
}

output "service_role_arn" {
  description = "IAM role ARN used by CodeBuild."
  value       = aws_iam_role.codebuild.arn
}

output "log_group_name" {
  description = "CloudWatch log group used by CodeBuild."
  value       = aws_cloudwatch_log_group.codebuild.name
}
