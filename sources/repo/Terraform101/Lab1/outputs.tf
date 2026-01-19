output "application_name" {
  value = var.application_name
}

output "environment_name" {
  value = var.environment_name

}

output "environment_prefix" {
  value = local.environment_prefix
}

output "sufix" {
  value = random_string.sufix.result

}


output "api_key" {
  value     = var.api_key
  sensitive = true
}

output "primary_region" {
  value = var.region[0]

}

output "primary_region_instance_count" {
  value = var.region_instance_count["West Europe"]
}

output "kind" {
  value = var.sku_settings.kind
}


output "regionA" {
  value = module.regional_stamps[0].name

}

output "regionB" {
  value = module.regional_stamps[1].name

}
