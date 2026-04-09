variable "application_name" {
  description = "The name of the application"
  type        = string

}

variable "application_name2" {
  description = "The name of another application"
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



variable "remote_access_users" {
  type = list(string)

}

variable "base_address_space" {
  type = string

}
