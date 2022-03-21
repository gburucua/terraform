variable "identifier" {
  description = "The name for the resource"
  type        = string
}

variable "associate_public_ip_address" {
  description = "Associate a public ip address with an instance in a VPC"
  default     = false
  type        = bool
}

variable "iam_instance_profile" {
  description = "The name attribute of the IAM instance profile to associate with launched instances"
  type        = string
}

variable "user_data" {
  description = "base64-encoded user-data"
  default     = ""
  type        = string
}

variable "security_groups" {
  description = "List of security groups to assign to instances"
  default     = []
  type        = list(string)
}

variable "ebs_optimized" {
  description = "If true, the launched EC2 instance will be EBS-optimized"
  default     = true
  type        = bool
}

variable "image_id" {
  description = "AMI to use"
  type        = string
}

variable "key_name" {
  description = "The name of the key-pair to use"
  type        = string
}

variable "volume_size" {
  description = "The size of the root ebs volume"
  default     = 20
  type        = number
}

variable "volume_type" {
  description = "The type of volume. Can be 'standard', 'gp2', or 'io1'"
  default     = "gp2"
  type        = string
}

variable "iops" {
  description = "The amount of provisioned IOPS"
  default     = null
  type        = number
}

variable "throughput" {
  description = "The throughput to provision"
  default     = null
  type        = number
}

variable "instance_type" {
  description = "EC2 Instance type to use"
  default     = "t2.micro"
  type        = string
}

variable "subnets" {
  description = "A list of subnet IDs to launch resources in"
  type        = list(string)
}

variable "min_size" {
  description = "Minimum number of instances in the ASG"
  default     = 1
  type        = number
}

variable "max_size" {
  description = "Maximun number of instances in the ASG"
  default     = 5
  type        = number
}

variable "health_check_grace_period" {
  description = "Time in seconds after instance comes into service before checking health"
  default     = 300
  type        = number
}

variable "eks_cluster_id" {
  description = "If set add the tag kubernetes.io/cluster/<cluster-name> = owned"
  default     = ""
  type        = string
}

variable "append_workspace" {
  description = "Appends the terraform workspace at the end of resource names, <identifier>-<worspace>"
  default     = true
  type        = bool
}

variable "tags" {
  description = "Tags to be applied to the resource"
  default     = {}
  type        = map(any)
}

variable "protect_from_scale_in" {
  description = "Allows setting instance protection. The autoscaling group will not select instances with this setting for termination during scale in events."
  default     = false
  type        = bool
}


variable "device_name" {
  description = "The name of the device to mount"
  default     = "/dev/xvda"
  type        = string
}

variable "delete_on_termination" {
  description = "Whether the network interface should be destroyed on instance termination"
  default     = true
  type        = bool
}

variable "encrypted" {
  description = "Enables EBS encryption on the volume"
  default     = false
  type        = bool
}

variable "update_default_version" {
  description = "Update the Launch template version"
  default     = true
  type        = bool
}

variable "instance_initiated_shutdown_behavior" {
  description = "The name for the resource"
  default     = "terminate"
  type        = string
}

variable "monitoring" {
  description = "The launched EC2 instance will have detailed monitoring enabled, if its true"
  default     = false
  type        = bool
}

variable "credit_specification" {
  description = "The credit specification of the instance standard / unlimited for T2/T3"
  default     = "standard"
  type        = string
}

variable "instance_market_options" {
  description = "(LT) The market (purchasing) option for the instance"
  type        = any
  default     = null
}

variable "resource_type" {
  description = "The type of resource to tag"
  default     = "instance"
  type        = string
}
