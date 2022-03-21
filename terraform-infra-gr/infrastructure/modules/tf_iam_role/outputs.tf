output "output" {
  value = {
    instance_profile = aws_iam_instance_profile.profile
    role             = aws_iam_role.role
  }
}
