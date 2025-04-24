variable "rhel_version" {
  description = "RHEL Version"
  default     = "RHEL9"
}

variable "ami_map" {
  type = map(string)
  default = {
    "RHEL7" = "ami-05ae892102a574172"
    "RHEL8" = "ami-06142a3457991a4a8"
    "RHEL9" = "ami-04f8d0dc7c0ac7a0e"
  }
}

variable "instance_name_convention" {
  description = "VM instance name convention"
  default     = "web"
}

variable "number_of_instances" {
  description = "VM number of instances"
  type        = number
  default     = 3
}
