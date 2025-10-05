output "vpc_id" {
  description = "Identifier of the provisioned VPC."
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets."
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets."
  value       = module.networking.private_subnet_ids
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer."
  value       = module.compute.alb_dns_name
}

output "asg_name" {
  description = "Name of the Auto Scaling Group managing the Nginx instances."
  value       = module.compute.asg_name
}
