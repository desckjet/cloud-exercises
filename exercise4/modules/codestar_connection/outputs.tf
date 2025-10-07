output "arn" {
  description = "ARN of the CodeStar connection."
  value       = aws_codestarconnections_connection.github.arn
}

output "name" {
  description = "Name of the CodeStar connection."
  value       = aws_codestarconnections_connection.github.name
}
