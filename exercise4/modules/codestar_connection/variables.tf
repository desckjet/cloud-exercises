variable "name_prefix" {
  description = "Prefix used for naming the CodeStar connection."
  type        = string
}

variable "codestar_connection_name" {
  description = "Optional override for the CodeStar connection name."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags applied to the CodeStar connection."
  type        = map(string)
  default     = {}
}
