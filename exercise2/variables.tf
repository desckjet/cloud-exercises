variable "project_name" {
  description = "Project identifier used for naming resources and the remote state bucket."
  type        = string
}

variable "environment" {
  description = "Environment name (for example dev, staging, prod)."
  type        = string
}

variable "state_bucket_name" {
  description = "Optional override for the remote state bucket name. Leave empty to derive from project and environment."
  type        = string
  default     = ""
}

variable "state_bucket_force_destroy" {
  description = "Whether to enable force_destroy on the remote state bucket."
  type        = bool
  default     = false
}

variable "aws_region" {
  description = "AWS region where resources will be created."
  type        = string
}

variable "az_count" {
  description = "Number of availability zones to use for public and private subnets."
  type        = number
  default     = 2

  validation {
    condition     = var.az_count >= 2
    error_message = "At least two availability zones are required."
  }
}

variable "vpc_cidr_block" {
  description = "CIDR block for the main VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_newbits" {
  description = "Number of additional prefix bits used when calculating subnet CIDR ranges from the VPC block."
  type        = number
  default     = 4
}

variable "launch_template_instance_type" {
  description = "Instance type for the Auto Scaling Group launch template."
  type        = string
  default     = "t2.micro"
}

variable "launch_template_ami_id" {
  description = "Optional AMI override for the launch template. Leave empty to use the latest Amazon Linux 2023 image."
  type        = string
  default     = ""
}

variable "asg_min_size" {
  description = "Minimum number of instances in the Auto Scaling Group."
  type        = number
  default     = 2
}

variable "asg_max_size" {
  description = "Maximum number of instances in the Auto Scaling Group."
  type        = number
  default     = 4

  validation {
    condition     = var.asg_max_size >= var.asg_min_size
    error_message = "asg_max_size must be greater than or equal to asg_min_size."
  }
}

variable "asg_desired_capacity" {
  description = "Desired number of instances in the Auto Scaling Group."
  type        = number
  default     = 2

  validation {
    condition     = var.asg_desired_capacity >= var.asg_min_size && var.asg_desired_capacity <= var.asg_max_size
    error_message = "asg_desired_capacity must fall between asg_min_size and asg_max_size."
  }
}

variable "alb_health_check_path" {
  description = "HTTP path used by the Application Load Balancer health checks."
  type        = string
  default     = "/"
}

variable "scale_out_cpu_threshold" {
  description = "CPU utilization percentage that triggers a scale-out alarm."
  type        = number
  default     = 60
}

variable "scale_in_cpu_threshold" {
  description = "CPU utilization percentage that triggers a scale-in alarm."
  type        = number
  default     = 20
}

variable "tags" {
  description = "Additional tags applied to supported resources."
  type        = map(string)
  default     = {}
}
