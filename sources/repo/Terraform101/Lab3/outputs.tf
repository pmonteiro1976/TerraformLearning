output "environment_name" {
  value       = var.environment_name
  description = "Environment name passed via tfvars"
}

output "creation_date" {
  value       = local.default_tags["Creationdate"]
  description = "Dynamic creation date used in tags"
}
