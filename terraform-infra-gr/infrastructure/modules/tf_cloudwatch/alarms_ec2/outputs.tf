output "output" {
  value = {
    alarm = aws_cloudwatch_metric_alarm.ec2_cpu
  }
}
