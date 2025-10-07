variable "name_prefix" {
  description = "Prefix used for naming CodeDeploy resources."
  type        = string
}

variable "app_name" {
  description = "CodeDeploy application name."
  type        = string
}

variable "deployment_group_name" {
  description = "CodeDeploy deployment group name."
  type        = string
}

variable "codedeploy_deployment_config" {
  description = "Deployment configuration for CodeDeploy."
  type        = string
}

variable "codedeploy_target_tag_key" {
  description = "EC2 tag key that identifies deployment targets."
  type        = string
}

variable "codedeploy_target_tag_value" {
  description = "EC2 tag value that identifies deployment targets."
  type        = string
}

variable "tags" {
  description = "Tags applied to CodeDeploy resources."
  type        = map(string)
  default     = {}
}
