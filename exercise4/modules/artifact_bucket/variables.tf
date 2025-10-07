variable "name_prefix" {
  description = "Prefix used for naming S3 resources."
  type        = string
}

variable "artifact_bucket_name" {
  description = "Optional override for the artifact bucket name."
  type        = string
  default     = ""
}

variable "artifact_bucket_force_destroy" {
  description = "Whether to enable force_destroy on the artifact bucket."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags applied to the artifact bucket."
  type        = map(string)
  default     = {}
}
