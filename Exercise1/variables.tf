variable "aws_region" {
  description = "AWS region where resources will be created."
  type        = string
}

variable "project_name" {
  description = "Project identifier used to name shared resources such as the state bucket."
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

variable "aws_config" {
  description = "AWS-specific configuration to be forwarded to the multicloud module."
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
    condition = (
      try(var.aws_config.key_name, null) != null ||
      try(var.aws_config.ssh_public_key, null) != null
    )
    error_message = "Provide either aws_config.key_name or aws_config.ssh_public_key to enable SSH access."
  }
}

variable "azure_config" {
  description = "Azure-specific configuration to be forwarded to the multicloud module."
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
}

variable "tags" {
  description = "Tags applied to resources created across clouds."
  type        = map(string)
  default     = {}
}
