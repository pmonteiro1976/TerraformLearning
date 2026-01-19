output "resource_group_name" {
  value       = azurerm_resource_group.main.name
  description = "Name of the deployed resource group"
}

output "resource_group_location" {
  value       = azurerm_resource_group.main.location
  description = "Location of the resource group"
}

output "resource_group_tags" {
  value       = azurerm_resource_group.main.tags
  description = "Tags applied to the resource group"
}

output "environment_name" {
  value       = var.environment_name
  description = "Environment name passed via tfvars"
}

output "creation_date" {
  value       = local.default_tags["Creationdate"]
  description = "Dynamic creation date used in tags"
}

output "container_name" {
  value = azurerm_storage_container.tfstate.name
}
