variable "name_prefix" {
  description = "Prefix used for naming CodeBuild related resources."
  type        = string
}

variable "project_name" {
  description = "CodeBuild project name."
  type        = string
}

variable "artifact_bucket_arn" {
  description = "ARN of the artifact bucket accessed by CodeBuild."
  type        = string
}

variable "aws_region" {
  description = "AWS region for CloudWatch Logs ARNs."
  type        = string
}

variable "tags" {
  description = "Tags applied to CodeBuild resources."
  type        = map(string)
  default     = {}
}

variable "codebuild_environment_image" {
  description = "Docker image used by CodeBuild."
  type        = string
}

variable "codebuild_compute_type" {
  description = "Compute type for CodeBuild."
  type        = string
}

variable "codebuild_environment_type" {
  description = "Runtime environment type for CodeBuild."
  type        = string
}

variable "codebuild_privileged_mode" {
  description = "Whether CodeBuild runs in privileged mode."
  type        = bool
}

variable "codebuild_build_timeout" {
  description = "Timeout for CodeBuild builds in minutes."
  type        = number
}

variable "codebuild_environment_variables" {
  description = "Environment variables passed to the CodeBuild project."
  type        = map(string)
}

variable "codebuild_buildspec" {
  description = "Optional inline buildspec definition."
  type        = string
  default     = null
}
