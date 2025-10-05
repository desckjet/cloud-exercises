variable "base_name" {
  description = "Base name used for naming alarms and policies."
  type        = string
}

variable "asg_name" {
  description = "Name of the Auto Scaling Group monitored by CloudWatch."
  type        = string
}

variable "scale_out_cpu_threshold" {
  description = "CPU utilization percentage that triggers a scale-out event."
  type        = number
}

variable "scale_in_cpu_threshold" {
  description = "CPU utilization percentage that triggers a scale-in event."
  type        = number
}

variable "tags" {
  description = "Tags applied to CloudWatch alarms."
  type        = map(string)
  default     = {}
}
