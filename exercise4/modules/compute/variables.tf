variable "name_prefix" {
  description = "Prefix used to name compute resources."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where resources will be created."
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs used by the load balancer."
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs used by the Auto Scaling group."
  type        = list(string)
}

variable "ami_id" {
  description = "AMI ID used in the launch template."
  type        = string
}

variable "instance_type" {
  description = "Instance type for CodeDeploy targets."
  type        = string
}

variable "iam_instance_profile_name" {
  description = "Name of the IAM instance profile attached to the EC2 instances."
  type        = string
}

variable "user_data" {
  description = "User data applied to the compute instances."
  type        = string
}

variable "asg_min_size" {
  description = "Minimum number of instances in the Auto Scaling group."
  type        = number
}

variable "asg_max_size" {
  description = "Maximum number of instances in the Auto Scaling group."
  type        = number
}

variable "asg_desired_capacity" {
  description = "Desired number of instances in the Auto Scaling group."
  type        = number
}

variable "alb_health_check_path" {
  description = "HTTP path used for ALB health checks."
  type        = string
  default     = "/"
}

variable "tags" {
  description = "Tags applied to compute resources."
  type        = map(string)
  default     = {}
}
