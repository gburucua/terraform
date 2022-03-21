output "output" {
  value = {
    launch_configuration = aws_launch_template.launch_temp
    autoscaling_group    = aws_autoscaling_group.asg
  }
}
