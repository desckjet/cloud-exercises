variable "aws_region" {
  description = "AWS region where the CI/CD resources will be created."
  type        = string
}

variable "name_prefix" {
  description = "Prefix used for naming all resources (e.g., project-env)."
  type        = string
  default     = "exercise4"
}

variable "tags" {
  description = "Common tags applied to all supported resources."
  type        = map(string)
  default     = {}
}

variable "project_name" {
  description = "Optional project identifier used to derive backend state bucket names."
  type        = string
  default     = ""
}

variable "environment" {
  description = "Optional environment identifier used for backend naming and tagging."
  type        = string
  default     = ""
}

variable "state_bucket_name" {
  description = "Override for the remote state bucket name. Leave empty to derive from project/environment or name_prefix."
  type        = string
  default     = ""
}

variable "state_bucket_force_destroy" {
  description = "Whether to enable force_destroy on the remote state bucket."
  type        = bool
  default     = false
}

variable "artifact_bucket_name" {
  description = "Optional name for the CodePipeline artifact bucket. Leave empty to generate a unique name."
  type        = string
  default     = ""
}

variable "artifact_bucket_force_destroy" {
  description = "Whether to enable force_destroy on the artifact bucket (useful for non-production)."
  type        = bool
  default     = false
}

variable "github_owner" {
  description = "GitHub organization or username that owns the repository."
  type        = string
}

variable "github_repository" {
  description = "Repository name (without the owner) to integrate with CodePipeline."
  type        = string
}

variable "github_branch" {
  description = "Git branch monitored by CodePipeline."
  type        = string
}

variable "codestar_connection_name" {
  description = "Name assigned to the AWS CodeStar connection to GitHub."
  type        = string
  default     = ""
}

variable "codebuild_environment_image" {
  description = "Docker image used by CodeBuild."
  type        = string
  default     = "aws/codebuild/standard:7.0"
}

variable "codebuild_compute_type" {
  description = "Compute type for CodeBuild (e.g., BUILD_GENERAL1_SMALL)."
  type        = string
  default     = "BUILD_GENERAL1_SMALL"
}

variable "codebuild_environment_type" {
  description = "Runtime environment type for CodeBuild."
  type        = string
  default     = "LINUX_CONTAINER"
}

variable "codebuild_privileged_mode" {
  description = "Enable privileged mode for Docker-in-Docker builds."
  type        = bool
  default     = false
}

variable "codebuild_build_timeout" {
  description = "Build timeout for CodeBuild in minutes."
  type        = number
  default     = 20
}

variable "codebuild_environment_variables" {
  description = "Environment variables passed to the CodeBuild project."
  type        = map(string)
  default     = {}
}

variable "codebuild_buildspec" {
  description = "Inline buildspec definition. Set to null to rely on buildspec.yml from the repository."
  type        = string
  default     = null
}

variable "codedeploy_target_tag_key" {
  description = "EC2 tag key that identifies CodeDeploy targets."
  type        = string
  default     = "CodeDeploy"
}

variable "codedeploy_target_tag_value" {
  description = "EC2 tag value that identifies CodeDeploy targets."
  type        = string
  default     = "Blue"
}

variable "codedeploy_deployment_config" {
  description = "Deployment config name for CodeDeploy."
  type        = string
  default     = "CodeDeployDefault.AllAtOnce"
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC provisioned in exercise4."
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_newbits" {
  description = "Additional bits used when calculating subnet CIDRs."
  type        = number
  default     = 4
}

variable "az_count" {
  description = "Number of availability zones to span the network."
  type        = number
  default     = 2
}

variable "compute_ami_id" {
  description = "Optional override for the CodeDeploy target AMI."
  type        = string
  default     = ""
}

variable "compute_instance_type" {
  description = "Instance type for the CodeDeploy target instances."
  type        = string
  default     = "t2.micro"
}

variable "asg_min_size" {
  description = "Minimum size for the Auto Scaling group hosting CodeDeploy targets."
  type        = number
  default     = 2
}

variable "asg_max_size" {
  description = "Maximum size for the Auto Scaling group hosting CodeDeploy targets."
  type        = number
  default     = 4
}

variable "asg_desired_capacity" {
  description = "Desired capacity for the Auto Scaling group hosting CodeDeploy targets."
  type        = number
  default     = 2
}

variable "alb_health_check_path" {
  description = "HTTP path used for Application Load Balancer health checks."
  type        = string
  default     = "/"
}
