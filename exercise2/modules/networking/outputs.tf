output "vpc_id" {
  description = "Identifier of the created VPC."
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets."
  value       = [for subnet in values(aws_subnet.public) : subnet.id]
}

output "private_subnet_ids" {
  description = "IDs of the private subnets."
  value       = [for subnet in values(aws_subnet.private) : subnet.id]
}
