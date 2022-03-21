output "output" {
  value = {
    # parameter_group = aws_db_parameter_group.main
    # ssm_parameter   = aws_ssm_parameter.secret
    # subnet_group    = aws_db_subnet_group.main
    rds               = aws_db_instance.main
  }
}
