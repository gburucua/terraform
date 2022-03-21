variable "identifier" {
  description = "Identifier for all the resource"
  default     = ""
  type        = string
}

variable "tags" {
  description = "Tags to be applied to the resource"
  default     = {}
  type        = map
}

variable "append_workspace" {
  description = "Appends the terraform workspace at the end of resource names, <identifier>-<worspace>"
  default     = true
  type        = bool
}

variable "load_balancer_id" {
  type        = string
  description = "ALB ID"
}

variable "target_group_id" {
  type        = string
  description = "Target Group ID"
}

variable "response_time_threshold" {
  type        = string
  default     = "50"
  description = "The average number of milliseconds that requests should complete within."
}

variable "unhealthy_hosts_threshold" {
  type        = string
  default     = "0"
  description = "The number of unhealthy hosts."
}

variable "evaluation_period" {
  type        = string
  default     = "5"
  description = "The evaluation period over which to use when triggering alarms."
}

variable "statistic_period" {
  type        = string
  default     = "60"
  description = "The number of seconds that make each statistic period."
}

variable "actions_alarm" {
  type        = list(string)
  default     = []
  description = "A list of actions to take when alarms are triggered. Will likely be an SNS topic for event distribution."
}

variable "actions_ok" {
  type        = list(string)
  default     = []
  description = "A list of actions to take when alarms are cleared. Will likely be an SNS topic for event distribution."
}
