output "artifact_bucket_name" {
  description = "Name of the S3 bucket storing CodePipeline artifacts."
  value       = module.artifact_bucket.bucket_name
}

output "pipeline_name" {
  description = "AWS CodePipeline name."
  value       = module.codepipeline.pipeline_name
}

output "pipeline_arn" {
  description = "AWS CodePipeline ARN."
  value       = module.codepipeline.pipeline_arn
}

output "codebuild_project_name" {
  description = "AWS CodeBuild project name."
  value       = module.codebuild.project_name
}

output "codebuild_project_arn" {
  description = "AWS CodeBuild project ARN."
  value       = module.codebuild.project_arn
}

output "codebuild_log_group" {
  description = "CloudWatch Log Group used by CodeBuild."
  value       = module.codebuild.log_group_name
}

output "codedeploy_application_name" {
  description = "AWS CodeDeploy application name."
  value       = module.codedeploy.application_name
}

output "codedeploy_application_arn" {
  description = "AWS CodeDeploy application ARN."
  value       = module.codedeploy.application_arn
}

output "codedeploy_deployment_group_name" {
  description = "AWS CodeDeploy deployment group name."
  value       = module.codedeploy.deployment_group_name
}

output "codedeploy_deployment_group_arn" {
  description = "AWS CodeDeploy deployment group ARN."
  value       = module.codedeploy.deployment_group_arn
}

output "codestar_connection_arn" {
  description = "ARN of the AWS CodeStar connection to GitHub."
  value       = module.codestar_connection.arn
}

output "vpc_id" {
  description = "Identifier of the VPC hosting the CodeDeploy targets."
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "Identifiers for the public subnets."
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Identifiers for the private subnets."
  value       = module.networking.private_subnet_ids
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer fronting the targets."
  value       = module.compute.alb_dns_name
}

output "autoscaling_group_name" {
  description = "Auto Scaling group name hosting the CodeDeploy instances."
  value       = module.compute.asg_name
}
