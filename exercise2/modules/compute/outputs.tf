output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer."
  value       = aws_lb.this.dns_name
}

output "alb_security_group_id" {
  description = "Security group ID attached to the ALB."
  value       = aws_security_group.alb.id
}

output "asg_security_group_id" {
  description = "Security group ID attached to the Auto Scaling Group instances."
  value       = aws_security_group.asg.id
}

output "asg_name" {
  description = "Name of the Auto Scaling Group."
  value       = aws_autoscaling_group.nginx.name
}

output "asg_arn" {
  description = "ARN of the Auto Scaling Group."
  value       = aws_autoscaling_group.nginx.arn
}

output "target_group_arn" {
  description = "ARN of the ALB target group."
  value       = aws_lb_target_group.nginx.arn
}
