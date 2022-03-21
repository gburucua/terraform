variable "region" {
  description = "The region where the resources will be deployed"
  type        = string
  default     = "us-east-1"
}

variable "identifier" {
  description = "ID for all resources"
  default     = "quorum"
  type        = string
}

# variable "custom_name_id" {
#   description = "The name custom for the resources"
#   type        = string
# }

variable "iam_policies_to_attach_worker" {
  description = "List of ARNs of IAM policies to attach"
  default = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/AmazonSSMDirectoryServiceAccess",
    "arn:aws:iam::aws:policy/AmazonSSMFullAccess",
    "arn:aws:iam::aws:policy/service-role/AmazonSSMMaintenanceWindowRole"
  ]
  type = list(string)
}

variable "instance_type" {
  description = "Instance type to use"
  default     = "t3.medium"
  type        = string
}

variable "cross_role" {
  description = "Cross account role to perform the deployment"
  default     = ""
  type        = string
}

variable "db_instance_type" {
  description = "DB Instance type to use"
  default     = "db.t3.large"
  type        = string
}

variable "es_instance_type" {
  description = "ES Instance type to use"
  default     = "m4.large.elasticsearch"
  type        = string
}

variable "ad_name" {
  description = "name of Active Directory"
  default     = ""
  type        = string
}

variable "private_subnets" {
  description = "List of all the private subnets"
  default     = []
  type        = list(string)
}

variable "public_subnets" {
  description = "List of all the public subnets"
  default     = []
  type        = list(string)
}

variable "db_subnets" {
  description = "List of all the db subnets"
  default     = []
  type        = list(string)
}

variable "tgw_subnets" {
  description = "List of all the db subnets"
  default     = []
  type        = list(string)
}

variable "tags" {
  description = "Tags to be applied to the resource"
  default = {
    Origin = "terraform"
    Owner  = "Cision"
  }
  type = map(any)
}

variable "vpc_id" {
  description = "VPC id for the resources"
  default     = ""
  type        = string
}

variable "ami_SecretSauce_SystemUpdate" {
  description = "AMI id to be used for ec2 instance"
  default     = ""
  type        = string
}

variable "ami_SecretSauce_JS" {
  description = "AMI id to be used for ec2 instance"
  default     = ""
  type        = string
}

variable "ami_SecretSauce_WS" {
  description = "AMI id to be used for ec2 instance"
  default     = ""
  type        = string
}

variable "ami_SecretSauce_TS" {
  description = "AMI id to be used for ec2 instance"
  default     = ""
  type        = string
}

variable "ami_SQL_Tool" {
  description = "AMI id to be used for ec2 instance"
  default     = ""
  type        = string
}

variable "ami_Jump_Box" {
  description = "AMI id to be used for ec2 instance"
  default     = ""
  type        = string
}

variable "ami_bamboo" {
  description = "AMI id to be used for ec2 instance"
  default     = ""
  type        = string
}

variable "ami_win_2019" {
  description = "AMI id to be used for ec2 instance"
  default     = ""
  type        = string
}

variable "ami_utility" {
  description = "AMI id to be used for ec2 instance"
  default     = ""
  type        = string
}

variable "ami_p2p" {
  description = "AMI id to be used for ec2 instance"
  default     = ""
  type        = string
}

variable "ami_p2p_nginx" {
  description = "AMI id to be used for ec2 instance"
  default     = ""
  type        = string
}

variable "ami_redis_slave" {
  description = "AMI id to be used for ec2 instance"
  default     = ""
  type        = string
}

variable "ami_redis_master" {
  description = "AMI id to be used for ec2 instance"
  default     = ""
  type        = string
}

variable "key_name" {
  description = "Keypair for ec2 instances"
  default     = ""
  type        = string
}

variable "rds_parameter_group_family" {
  description = "Parameter group family"
  default     = "sqlserver-se-15.0"
  type        = string
}

variable "acl" {
  description = "Access list for the bucket"
  default     = "private"
  type        = string
}

variable "bucket" {
  description = "Bucket name"
  default     = ""
  type        = string
}

variable "append_workspace" {
  description = "Appends the terraform workspace at the end of resource names, <identifier>-<worspace>"
  default     = true
  type        = bool
}

variable "engine" {
  description = "Define the engine for the database"
  type        = string
}

variable "rds_engine_version" {
  description = "Engine version for the db"
  type        = string
}

# variable "domain" {
#   description = "Name of domain for AD"
#   type        = string
# }
