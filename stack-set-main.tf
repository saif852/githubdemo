resource "aws_cloudformation_stack_set_instance" "stack_instances" {
  count = length(var.regions) * length(var.account_ids)

  stack_set_name = var.stack_set_name
  region         = var.regions[count.index / length(var.account_ids)]
  account_id     = var.account_ids[count.index % length(var.account_ids)]

  dynamic "parameter_overrides" {
    for_each = var.parameter_overrides

    content {
      parameter_key   = parameter_overrides.key
      parameter_value = parameter_overrides.value
    }
  }
}

output "stack_instance_ids" {
  description = "The IDs of the created stack instances."
  value       = aws_cloudformation_stack_set_instance.stack_instances[*].id
}
