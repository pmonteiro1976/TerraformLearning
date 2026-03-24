variable "location" {
  description = "Azure region where resources will be deployed"
  type        = string
}

variable "resource_group_name" {
  description = "Resource Group name"
  type        = string
}

variable "storage_account_name" {
  description = "Storage Account name (must be globally unique)"
  type        = string
}

variable "container_name" {
  description = "Blob container name"
  type        = string
  default     = "lab-container"
}