variable "location" {
  type        = string
  description = "Region of the Infrastructure"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the Resource Group"

}

variable "sku" {
  type        = string
  description = "SKU of the Container Group"
  default     = "Basic"

}

variable "os_type" {
  type        = string
  description = "OS for the container group"
  default     = "Linux"

}

variable "registry_name" {
  type        = string
  description = "Name of the Container Registry"
}

variable "container_group_name" {
  description = "The name of the Container Group"
  type        = string
}

variable "dns_label" {
  type        = string
  description = "The DNS label/name for the container group's IP"
}