variable "location" {
  type        = string
  description = "Region of the resource group"
  default     = "westeurope"
}

variable "rg_name" {
  type        = string
  description = "Name of the resource group"
  default     = "rg_vnet"

}

variable "vnet_name" {
  type        = string
  description = "Name of the Virtual Network"
  default     = "lab_vnet"

}

variable "address_space" {
  type        = string
  description = "CIDR for VNET"
  default     = "10.0.0.0/16"

}