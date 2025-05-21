variable "rhel_version" {
  description = "RHEL Version"
  default     = "RHEL9"
}

variable "ticket_number" {
  description = "SNOW Ticket Number"
  default     = ""
}

variable "ami_map" {
  type = map(string)
  default = {
    "RHEL7" = "ami-05ae892102a574172"
    "RHEL8" = "ami-06142a3457991a4a8"
    "RHEL9" = "ami-04f8d0dc7c0ac7a0e"
  }
}

variable "lookup_map" {
  type = map(string)
  default = {
    "RHEL7" = "RHEL-7.9"
    "RHEL8" = "RHEL-8.10"
    "RHEL9" = "RHEL-9.6"
    "RHEL10" = "RHEL-10.0"
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
