variable "aws_config" {
  description = "Configuration parameters for the AWS EC2 deployment."
  type = object({
    name_prefix              = string
    vpc_cidr_block           = string
    public_subnet_cidr_block = string
    instance_type            = string
    ami_id                   = string
    key_name                 = optional(string)
    ssh_public_key           = optional(string)
    allowed_ssh_cidr_blocks  = list(string)
    iam_role_name            = string
    iam_inline_policy_json   = optional(string)
    enable_public_ip         = optional(bool, true)
    root_volume_size_gb      = optional(number, 20)
    tags                     = optional(map(string), {})
  })

  validation {
    condition     = can(cidrnetmask(var.aws_config.vpc_cidr_block)) && can(cidrnetmask(var.aws_config.public_subnet_cidr_block))
    error_message = "The AWS VPC and subnet CIDR blocks must be valid CIDR addresses."
  }

  validation {
    condition     = length(var.aws_config.allowed_ssh_cidr_blocks) > 0
    error_message = "At least one CIDR block must be provided for allowed SSH access in AWS."
  }

  validation {
    condition = (
      try(var.aws_config.key_name, null) != null ||
      try(var.aws_config.ssh_public_key, null) != null
    )
    error_message = "Provide either aws_config.key_name or aws_config.ssh_public_key to enable SSH access."
  }
}

variable "azure_config" {
  description = "Configuration parameters for the Azure VM deployment."
  type = object({
    name_prefix                  = string
    resource_group_name          = string
    location                     = string
    vnet_address_space           = list(string)
    subnet_address_prefix        = string
    vm_size                      = string
    admin_username               = string
    admin_ssh_public_key         = string
    allowed_ssh_source_addresses = list(string)
    image_reference = object({
      publisher = string
      offer     = string
      sku       = string
      version   = string
    })
    enable_public_ip = optional(bool, true)
    os_disk_size_gb  = optional(number, 64)
    tags             = optional(map(string), {})
  })

  validation {
    condition     = length(var.azure_config.allowed_ssh_source_addresses) > 0
    error_message = "At least one source CIDR must be supplied for Azure SSH access."
  }

  validation {
    condition     = length(var.azure_config.vnet_address_space) > 0
    error_message = "At least one address space must be provided for the Azure virtual network."
  }
}

variable "tags" {
  description = "Common tags applied to all resources."
  type        = map(string)
  default     = {}
}
