output "vpc_id" {
  description = "Identifier of the created VPC."
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "Identifiers of the public subnets."
  value       = [for subnet in aws_subnet.public : subnet.id]
}

output "private_subnet_ids" {
  description = "Identifiers of the private subnets."
  value       = [for subnet in aws_subnet.private : subnet.id]
}
