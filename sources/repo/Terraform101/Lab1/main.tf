resource "random_string" "sufix" {
  length = 6
  upper  = false
}

locals {
  environment_prefix = "${var.application_name}-${var.environment_name}- ${random_string.sufix.result}"

  regional_stamp_names = [
    {
      region         = "westus"
      name           = "foo"
      min_node_count = 4
      max_node_count = 8
    },
    {
      region         = "eastus"
      name           = "bar"
      min_node_count = 4
      max_node_count = 8
    }
  ]
}



module "regional_stamps" {
  source = "./modules/regional-stamp"

  count = length(local.regional_stamp_names)

  region         = local.regional_stamp_names[count.index].region
  name           = local.regional_stamp_names[count.index].name
  min_node_count = local.regional_stamp_names[count.index].min_node_count
  max_node_count = local.regional_stamp_names[count.index].max_node_count

}
