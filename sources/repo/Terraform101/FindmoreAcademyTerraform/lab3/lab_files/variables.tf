variable "location" {
  type        = string
  description = "Region of the resource group"
  default     = "northeurope"
}

variable "rg_name" {
  type        = string
  description = "Name of the resource group"
  default     = "rg1"

}

variable "vnet_name" {
  type        = string
  description = "Name of the Virtual Network"
  default     = "vnet_lab"

}

variable "address_space" {
  type        = string
  description = "CIDR for VNET"
  default     = "10.100.0.0/16"

}