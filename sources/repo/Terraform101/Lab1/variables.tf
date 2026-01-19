variable "application_name" {
  type = string

  validation {
    condition     = length(var.application_name) >= 4 && length(var.application_name) <= 10
    error_message = "The application name must be between 3 and 10 characters long."
  }

}

variable "environment_name" {
  type = string
}

variable "api_key" {
  sensitive = true
}

variable "instance_count" {
  type = number

  validation {
    condition     = var.instance_count >= 1 && var.instance_count <= 5
    error_message = "The instance count must be between 1 and 5."
  }
}

variable "enable" {
  type = bool

}

variable "region" {
  type = list(string)
}

variable "region_instance_count" {
  type = map(number)

}

variable "region_set" {
  type = set(string)

}

variable "sku_settings" {
  type = object({
    kind = string
    tier = string
  })

}


