variable "name_prefix" {
  description = "Prefix used for naming CodePipeline resources."
  type        = string
}

variable "pipeline_name" {
  description = "CodePipeline name."
  type        = string
}

variable "artifact_bucket_name" {
  description = "Artifact bucket name used by CodePipeline."
  type        = string
}

variable "artifact_bucket_arn" {
  description = "Artifact bucket ARN used by CodePipeline."
  type        = string
}

variable "aws_region" {
  description = "AWS region where CodePipeline runs."
  type        = string
}

variable "aws_account_id" {
  description = "AWS account ID that owns the resources."
  type        = string
}

variable "codestar_connection_arn" {
  description = "CodeStar connection ARN for the source stage."
  type        = string
}

variable "github_owner" {
  description = "GitHub owner for the source repository."
  type        = string
}

variable "github_repository" {
  description = "GitHub repository name for the source stage."
  type        = string
}

variable "github_branch" {
  description = "Git branch tracked by the pipeline."
  type        = string
}

variable "codebuild_project_name" {
  description = "CodeBuild project name referenced by the pipeline."
  type        = string
}

variable "codebuild_project_arn" {
  description = "CodeBuild project ARN referenced by the pipeline."
  type        = string
}

variable "codebuild_role_arn" {
  description = "IAM role ARN used by CodeBuild, required for PassRole."
  type        = string
}

variable "codedeploy_application_name" {
  description = "CodeDeploy application name referenced by the pipeline."
  type        = string
}

variable "codedeploy_application_arn" {
  description = "CodeDeploy application ARN referenced by the pipeline."
  type        = string
}

variable "codedeploy_deployment_group_name" {
  description = "CodeDeploy deployment group name referenced by the pipeline."
  type        = string
}

variable "codedeploy_deployment_group_arn" {
  description = "CodeDeploy deployment group ARN referenced by the pipeline."
  type        = string
}

variable "codedeploy_role_arn" {
  description = "IAM role ARN used by CodeDeploy, required for PassRole."
  type        = string
}

variable "codedeploy_deployment_config_name" {
  description = "Deployment config name used by CodeDeploy."
  type        = string
}

variable "tags" {
  description = "Tags applied to CodePipeline resources."
  type        = map(string)
  default     = {}
}
