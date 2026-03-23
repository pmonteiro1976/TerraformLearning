# Lab 4 — Implementing Terraform Modules with Azure Containers
**Lab Overview** 

In this lab, you will learn how to create and use Terraform modules to deploy reusable infrastructure components.

Instead of defining all resources in a single Terraform configuration, we will encapsulate infrastructure logic inside a Terraform module and deploy it from a root module.

The module created in this lab will provision:

- An Azure Container Registry (ACR) to store container images

- An Azure Container Instance (ACI) that runs a container workload

By the end of the lab, you will deploy a containerized application using a reusable Terraform module and retrieve the public endpoint of the running container.

---

# Lab Architecture

Each module instance will deploy the following infrastructure:

```
Terraform Root Module
        │
        ▼
   Container Module
        │
        ├── Azure Container Registry
        └── Azure Container Instance
```

This demonstrates how Terraform modules can group multiple resources into a reusable infrastructure component.

---

# Lab Objectives

After completing this lab, you will be able to:

- Create a Terraform module

- Define module variables

- Deploy resources using a module

- Reference existing infrastructure using data sources

- Retrieve information using Terraform outputs

---

# Step 1 — Create the Project Structure

Create the following folder structure:

```
terraform-lab
│
├ main.tf
├ variables.tf
├ outputs.tf
├ providers.tf
│
└ modules
     └ container-app
          ├ main.tf
          ├ variables.tf
          └ outputs.tf

```

The root module orchestrates the deployment, while the container module defines the infrastructure resources.

---

# Step 2 — Implement the Module

Open the following file:

`modules/container-app/main.tf`

Add the following configuration:

```
resource "azurerm_container_registry" "acr" {
  name                = var.registry_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = true
}

resource "azurerm_container_group" "container" {
  name                = var.container_group_name
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"

  container {
    name   = "hello-container"
    image  = "mcr.microsoft.com/azuredocs/aci-helloworld"
    cpu    = "0.5"
    memory = "1"

    ports {
      port     = 80
      protocol = "TCP"
    }
  }

  ip_address_type = "Public"
  dns_name_label  = var.dns_label
}
```

This module creates:

- A container registry

- A container instance running a public demo container

---

# Step 3 — Define Module Variables

Create the file:

`modules/container-app/variables.tf`

```
variable "resource_group_name" {
  description = "Resource group where resources will be deployed"
  type        = string
}

variable "location" {
  description = "Azure region for deployment"
  type        = string
}

variable "registry_name" {
  description = "Name of the Azure Container Registry"
  type        = string
}

variable "container_group_name" {
  description = "Name of the container group"
  type        = string
}

variable "dns_label" {
  description = "Public DNS label for the container instance"
  type        = string
}

```

# Step 4 — Define Module Outputs

Create the file:

`modules/container-app/outputs.tf`

```
output "container_fqdn" {
  value = azurerm_container_group.container.fqdn
}
```

This output exposes the public endpoint of the container instance.

---

# Step 5 — Reference an Existing Resource Group

For this lab, the Resource Group is already created beforehand in the Azure Portal, so we will only reference it using a data source.

Add the following configuration to `main.tf` in the root module:

```
data "azurerm_resource_group" "rg" {
  name = "RESOURCE_GROUP_NAME_PORTAL"
}
```

This tells Terraform to retrieve information about an existing resource group.

---

# Step 6 — Deploy the Module

Still in the root `main.tf`, call the module:

```
module "container_app" {
  source = "./modules/container-app"

  resource_group_name  = data.azurerm_resource_group.rg.name
  location             = data.azurerm_resource_group.rg.location
  registry_name        = var.registry_name
  container_group_name = var.container_group_name
  dns_label            = var.dns_label
}
```

Here we pass:

- the resource group retrieved via data source

- variables defined in the root module

--- 

# Step 7 — Define Root Variables

Create `variables.tf` in the root directory.

```
variable "registry_name" {
  description = "Container registry name"
}

variable "container_group_name" {
  description = "Container group name"
}

variable "dns_label" {
  description = "DNS label for container instance"
}
```
---

# Step 8 — Initialize Terraform

Run the following command to initialize the Terraform working directory and the module:

`terraform init`

**OBS:** Every update on the modules requires a new  `terraform init` to reload the module definitions.

---

# Step 9 — Review the Execution Plan

Before deploying resources, review the execution plan:

`terraform plan`

Terraform will show which resources will be created.

---

# Step 10 — Deploy the Infrastructure

Apply the Terraform configuration:

`terraform apply`

Confirm the deployment when prompted.

---

# Step 11 — Verify the Deployment

Once the deployment completes, retrieve the container endpoint.

You can open the container URL in your browser to verify the application is running.

<img width="633" height="363" alt="image" src="https://github.com/user-attachments/assets/49bf90d4-aad0-4b75-b578-ee12c7ee18b3" />

The container runs a demo application called:

`ACI Hello World`

# Expected Result

Your Terraform deployment will create the following resources:

| Resource            | Description                     |
|---------------------|---------------------------------|
| Container Registry  | Stores container images         |
| Container Instance  | Runs the container workload     |
| Public Endpoint     | Accessible container application |

---

# Lab Wrap-Up

In this lab, you learned how to:

- Build a Terraform module

- Deploy multiple Azure resources as a reusable unit

- Reference existing infrastructure using data sources

- Pass variables to modules

- Expose outputs from modules

Terraform modules enable teams to create reusable infrastructure components, improving maintainability, consistency, and scalability across environments.
