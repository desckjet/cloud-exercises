output "aws" {
  description = "Surface selected AWS metadata from the module."
  value       = module.multicloud_instance.aws
}

output "azure" {
  description = "Surface selected Azure metadata from the module."
  value       = module.multicloud_instance.azure
}
