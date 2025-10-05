resource "aws_autoscaling_policy" "scale_out" {
  name                   = "${var.base_name}-scale-out"
  autoscaling_group_name = var.asg_name
  policy_type            = "SimpleScaling"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 120
}

resource "aws_autoscaling_policy" "scale_in" {
  name                   = "${var.base_name}-scale-in"
  autoscaling_group_name = var.asg_name
  policy_type            = "SimpleScaling"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 180
}

resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.base_name}-high-cpu"
  alarm_description   = "Scale out when average CPU exceeds threshold"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = var.scale_out_cpu_threshold
  treat_missing_data  = "notBreaching"

  dimensions = {
    AutoScalingGroupName = var.asg_name
  }

  alarm_actions = [aws_autoscaling_policy.scale_out.arn]

  tags = merge(var.tags, {
    Name = "${var.base_name}-high-cpu"
  })
}

resource "aws_cloudwatch_metric_alarm" "low_cpu" {
  alarm_name          = "${var.base_name}-low-cpu"
  alarm_description   = "Scale in when average CPU drops below threshold"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 4
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = var.scale_in_cpu_threshold
  treat_missing_data  = "breaching"

  dimensions = {
    AutoScalingGroupName = var.asg_name
  }

  alarm_actions = [aws_autoscaling_policy.scale_in.arn]

  tags = merge(var.tags, {
    Name = "${var.base_name}-low-cpu"
  })
}
