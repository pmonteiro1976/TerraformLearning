# Terraform provider
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }
}
# Provider declaration
provider "azurerm" {
  features {}

}

# data sourcing the existing Resource Group for your region (Check on Portal)
data "azurerm_resource_group" "rg" {
  name = "RESOURCE_GROUP_NAME_PORTAL"
  
}

# Container app module call
module "container_app" {
  source = "./modules/container-app"

  resource_group_name  = data.azurerm_resource_group.rg.name
  location             = data.azurerm_resource_group.rg.location
  registry_name        = var.registry_name
  container_group_name = var.container_group_name
  dns_label            = var.dns_label
}