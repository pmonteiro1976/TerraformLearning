variable "prefix" { type = string }

variable "location" { 
    type = string 
    default = "Germany West Central"
    }

variable "random_suffix_length" {
  type    = number
  default = 4
}

variable "vnet_address_space" {
  type    = list(string)
  default = ["10.0.0.0/16"]
}

variable "subnet_name" {
  type    = string
  default = "subnet1"
}

variable "subnet_address_prefixes" {
  type    = list(string)
  default = ["10.0.1.0/24"]
}

variable "private_ip_allocation" {
  type    = string
  default = "Dynamic"
}

variable "vm_size" {
  type    = string
  default = "Standard_B2ls_v2"
}

variable "admin_username" { type = string }

variable "admin_password" {
  type      = string
  sensitive = true
}

variable "disable_password_authentication" {
  type    = bool
  default = false
}

variable "os_type" {
  type    = string
  default = "Linux"
}

variable "os_disk_caching" {
  type    = string
  default = "ReadWrite"
}

variable "os_disk_storage_account_type" {
  type    = string
  default = "Standard_LRS"
}

variable "image_publisher" {
  type    = string
  default = "Canonical"
}

variable "image_offer" {
  type    = string
  default = "0001-com-ubuntu-server-jammy"
}

variable "image_sku" {
  type    = string
  default = "22_04-lts"
}

variable "image_version" {
  type    = string
  default = "latest"
}

variable "zone" {
  type = string

}