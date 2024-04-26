variable "stack_set_name" {
  description = "The name of the CloudFormation stack set."
  type        = string
}

variable "regions" {
  description = "A list of AWS regions where the stack instances will be created."
  type        = list(string)
}

variable "account_ids" {
  description = "A list of AWS account IDs where the stack instances will be created."
  type        = list(string)
}

variable "parameter_overrides" {
  description = "A map of parameter overrides for the stack instances."
  type        = map(any)
  default     = {}
}
