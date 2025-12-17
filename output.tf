# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "vm_name_terraformvms" {
  value = aws_instance.terraformvms[*].tags.Name
}

output "action_results" {
  value = aws_instance.terraformvms[*].action
}
