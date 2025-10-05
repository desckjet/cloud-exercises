variable "base_name" {
  description = "Base name used for naming resources."
  type        = string
}

variable "vpc_id" {
  description = "Identifier of the VPC that hosts the compute resources."
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs used by the Application Load Balancer."
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_ids) >= 2
    error_message = "Provide at least two public subnet IDs."
  }
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs used by the Auto Scaling Group."
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_ids) >= 2
    error_message = "Provide at least two private subnet IDs."
  }
}

variable "ami_id" {
  description = "AMI used by the launch configuration."
  type        = string
}

variable "instance_type" {
  description = "Instance type for the Auto Scaling Group."
  type        = string
}

variable "user_data" {
  description = "Bootstrap script executed on instance launch."
  type        = string
}

variable "asg_min_size" {
  description = "Minimum number of instances in the Auto Scaling Group."
  type        = number
}

variable "asg_max_size" {
  description = "Maximum number of instances in the Auto Scaling Group."
  type        = number
}

variable "asg_desired_capacity" {
  description = "Desired number of instances in the Auto Scaling Group."
  type        = number
}

variable "alb_health_check_path" {
  description = "HTTP path used by the ALB health check."
  type        = string
}

variable "tags" {
  description = "Tags applied to compute resources."
  type        = map(string)
  default     = {}
}
