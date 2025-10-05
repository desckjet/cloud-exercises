variable "base_name" {
  description = "Base name used to construct resource names."
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "subnet_newbits" {
  description = "Additional prefix bits used to calculate subnet CIDR blocks."
  type        = number
}

variable "availability_zones" {
  description = "Availability zones used for subnet placement."
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "Provide at least two availability zones."
  }
}

variable "tags" {
  description = "Tags applied to network resources."
  type        = map(string)
  default     = {}
}
