# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED MODULE PARAMETERS
# These variables must be passed in by the operator.
# ---------------------------------------------------------------------------------------------------------------------

variable "db_password" {
  description = "The password used to log in to the DB"
}

variable "ip_address_for_ssh" {
  description = "Your IP address - used to enable SSH access from your computer into public hosts"
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL MODULE PARAMETERS
# These variables have defaults, but may be overridden by the operator.
# ---------------------------------------------------------------------------------------------------------------------

variable "aws_profile" {
  description = "The profile associated with the aws account you want to create resources for."
  default     = "personal-website-mcgradyc"
}

variable "aws_region" {
  description = "The region you want to create resources for."
  default     = "us-west-2"
}

variable "key_pair_name" {
  description = "The name of the Key Pair that can be used to SSH to each EC2 instance in the ECS cluster. Leave blank to not include a Key Pair."
  default     = "charliemcgrady-ssh-key-pair"
}

variable "node_server_image" {
  description = "The name of the Docker image to deploy for server"
  default     = "168870951978.dkr.ecr.us-west-2.amazonaws.com/node-server"
}

variable "node_server_image_version" {
  description = "The version (i.e. tag) of the Docker container to deploy for the server. Generally, use ../bin/release.sh to manage this value"
  default     = "2A1D2260-60BF-4050-B2C4-A7BF17869CA3"
}

variable "node_server_port" {
  description = "The port the node server listens on for HTTP requests (e.g. 4000)"
  default     = 4000
}

variable "ecs_cluster_name" {
  description = "The name used for the ECS cluster"
  default     = "charliemcgrady-production-cluster"
}
