output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer."
  value       = aws_lb.this.dns_name
}

output "asg_name" {
  description = "Name of the Auto Scaling group hosting the CodeDeploy targets."
  value       = aws_autoscaling_group.this.name
}

output "instance_security_group_id" {
  description = "Security group ID assigned to the target instances."
  value       = aws_security_group.instances.id
}
