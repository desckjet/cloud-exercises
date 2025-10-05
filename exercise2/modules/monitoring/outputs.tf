output "scale_out_policy_arn" {
  description = "ARN of the scale-out policy."
  value       = aws_autoscaling_policy.scale_out.arn
}

output "scale_in_policy_arn" {
  description = "ARN of the scale-in policy."
  value       = aws_autoscaling_policy.scale_in.arn
}

output "high_cpu_alarm_name" {
  description = "Name of the high CPU CloudWatch alarm."
  value       = aws_cloudwatch_metric_alarm.high_cpu.alarm_name
}

output "low_cpu_alarm_name" {
  description = "Name of the low CPU CloudWatch alarm."
  value       = aws_cloudwatch_metric_alarm.low_cpu.alarm_name
}
