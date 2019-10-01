# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED MODULE PARAMETERS
# These variables must be passed in by the operator.
# ---------------------------------------------------------------------------------------------------------------------

variable "name" {
  description = "The name of the VPC"
}

variable "ip_address_for_ssh" {
  description = "Your IP address - used to enable SSH access from your computer into public hosts"
}
