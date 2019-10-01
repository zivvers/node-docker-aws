# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED MODULE PARAMETERS
# These variables must be passed in by the operator.
# ---------------------------------------------------------------------------------------------------------------------

variable "name" {
  description = "The name of the RDS DB"
}

variable "subnet_ids" {
  description = "The subnet IDs in which to deploy the RDS DB"
  type        = "list"
}

variable "vpc_id" {
  description = "The ID of the VPC in which to deploy the RDS DB"
}

variable "password" {
  description = "The password used to log in to the DB"
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL MODULE PARAMETERS
# These variables have defaults, but may be overridden by the operator.
# ---------------------------------------------------------------------------------------------------------------------

variable "username" {
  description = "The username to be used to access the DB"
  default     = "postgres"
}

variable "port" {
  description = "The port to run the DB connections on"
  default     = 5432
}

variable "engine_name" {
  description = "The DB engine to use"
  default     = "postgres"
}

variable "engine_version" {
  description = "The version of the DB engine to use"
  default     = 11.5
}

variable "allocated_storage" {
  description = "Disk space to be allocated to the DB instance"
  default     = 20
}

variable "database_name" {
  description = "The name of the database to create when the DB instance is created"
  default     = "charliemcgrady"
}
