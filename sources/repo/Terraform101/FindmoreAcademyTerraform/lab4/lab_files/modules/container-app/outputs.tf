output "container_fqdn" {
  value       = azurerm_container_group.container.fqdn
  description = "Container Instance FQDN"
}