# ----------------------------
# Providers
# ----------------------------

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }

  }
}

provider "azurerm" {
  features {}
}



# ----------------------------
# Variable
# ----------------------------
variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "West Europe"
}

variable "prefix" { type = string }

variable "random_suffix_length" {
  type    = number
  default = 6
}


# ----------------------------
# Random string for naming
# ----------------------------
resource "random_string" "suffix" {
  length  = var.random_suffix_length
  special = false
  upper   = false
}

# ----------------------------
# Resource Group
# ----------------------------
resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-rg"
  location = var.location
}

# ----------------------------
# Storage Account
# ----------------------------
resource "azurerm_storage_account" "storage" {
  name                     = "${var.prefix}sto${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  public_network_access_enabled = true
}

# ----------------------------
# Storage Container
# ----------------------------
resource "azurerm_storage_container" "container" {
  name                  = "public-container"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "blob"
}

# ----------------------------
# Sample Blob
# ----------------------------
resource "azurerm_storage_blob" "sample" {
  name                   = "hello.txt"
  storage_account_name   = azurerm_storage_account.storage.name
  storage_container_name = azurerm_storage_container.container.name
  type                   = "Block"
  source_content         = "Hello from Terraform!"
}

# ----------------------------
# Outputs
# ----------------------------
output "blob_url" {
  description = "Public URL of the uploaded blob"
  value       = "${azurerm_storage_account.storage.primary_blob_endpoint}${azurerm_storage_container.container.name}/${azurerm_storage_blob.sample.name}"
}