variable "application_name" {
  description = "The name of the application"
  type        = string

}

variable "environment_name" {
  description = "The environment for the resources"
  type        = string
}

variable "primary_location" {
  description = "The Azure region where resources will be created"
  type        = string
  validation {
    condition     = contains(keys(local.region_code_map), var.primary_location)
    error_message = "Invalid region. Must be one of: Germany West Central, West Europe, etc."
  }

}