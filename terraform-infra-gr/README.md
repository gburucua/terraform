# terraform-infra-gr
A repository used for all infrastructure automation done with terraform for GR project

s3-state-bucket folder will be used to deploy remote state in AWS.
infrastructure folder will be used to deploy infrastructure into AWS.


Currently AMIs are passed through the <ENV>-quorum.tfvars file. This variables will overload the variables.tf files and will create ec2 instances with this images as base AMIs.
