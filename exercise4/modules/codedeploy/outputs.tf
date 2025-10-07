output "application_name" {
  description = "CodeDeploy application name."
  value       = aws_codedeploy_app.app.name
}

output "application_arn" {
  description = "CodeDeploy application ARN."
  value       = aws_codedeploy_app.app.arn
}

output "deployment_group_name" {
  description = "CodeDeploy deployment group name."
  value       = aws_codedeploy_deployment_group.deployment_group.deployment_group_name
}

output "deployment_group_arn" {
  description = "CodeDeploy deployment group ARN."
  value       = aws_codedeploy_deployment_group.deployment_group.arn
}

output "service_role_arn" {
  description = "IAM role ARN used by CodeDeploy."
  value       = aws_iam_role.codedeploy.arn
}
