output "environment_name" {
  value       = var.environment_name
  description = "Environment name passed via tfvars"
}

output "creation_date" {
  value       = local.default_tags["Creationdate"]
  description = "Dynamic creation date used in tags"
}


output "regioncode" {
  value       = local.region_code
  description = "Dynamic creation region used in main locals"

}


output "public_ip_address" {
  value = azurerm_public_ip.vm1.ip_address

}