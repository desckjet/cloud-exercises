variable "name_prefix" {
  description = "Prefix used for naming the IAM role and instance profile."
  type        = string
}

variable "managed_policy_arns" {
  description = "Managed policies attached to the instance role."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags applied to the IAM role."
  type        = map(string)
  default     = {}
}
