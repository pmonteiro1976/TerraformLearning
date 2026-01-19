environment_name = "dev"
instance_count   = 4
enable           = true
api_key          = "prod-12345"
region           = ["East US", "West Europe"] // you can access by index
region_instance_count = {
  "East US"     = 8
  "West Europe" = 4
} // you can access by index

region_set = ["East US", "West Europe", "Southeast Asia"] //no order here

sku_settings = {
  kind = "p"
  tier = "business"
}
