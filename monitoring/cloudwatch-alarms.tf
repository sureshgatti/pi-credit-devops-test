variable "env" {
  default = "stagging"
}

resource "aws_cloudwatch_metric_alarm" "asg_cpu_high" {
  alarm_name          = "pi-credit-${var.env}-asg-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "High CPU on ASG instances"
}
