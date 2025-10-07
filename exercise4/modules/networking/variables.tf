variable "name_prefix" {
  description = "Prefix used to name networking resources."
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "subnet_newbits" {
  description = "Number of additional bits for subnet CIDR calculations."
  type        = number
  default     = 4
}

variable "availability_zones" {
  description = "List of availability zones to span the network across."
  type        = list(string)
}

variable "tags" {
  description = "Tags applied to networking resources."
  type        = map(string)
  default     = {}
}
