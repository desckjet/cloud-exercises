output "role_name" {
  description = "Name of the IAM role assigned to EC2 instances."
  value       = aws_iam_role.this.name
}

output "role_arn" {
  description = "ARN of the IAM role assigned to EC2 instances."
  value       = aws_iam_role.this.arn
}

output "instance_profile_name" {
  description = "IAM instance profile name for EC2 instances."
  value       = aws_iam_instance_profile.this.name
}
