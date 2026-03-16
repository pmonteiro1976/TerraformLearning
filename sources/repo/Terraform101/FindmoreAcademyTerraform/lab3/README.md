# Lab 3 — Configuring Remote Backend in Azure & Using Terraform Import

## Objective

In this lab you will learn how to:

* Import **existing Azure resources** into Terraform state
* Understand the **Terraform Import workflow**
* Configure a **remote backend using Azure Storage**
* **Migrate local Terraform state** to a remote backend

This is a common real-world scenario. Infrastructure often already exists in the cloud, and Terraform must **adopt and manage those resources without recreating them**.

---

# Scenario

Some Azure resources have **already been created** in the subscription:

* A **Resource Group**
* A **Virtual Network**
* A **Storage Account and Blob Container** (used for Terraform remote backend)

Your task is to:

1. Write Terraform code describing the existing resources
2. Import them into Terraform state
3. Verify the import using `terraform plan`
4. Adjust the code until Terraform detects **no changes**
5. Configure a **remote backend**
6. Migrate the Terraform state to Azure Storage

You will repeat the **Terraform Import cycle**:

`
Write Code → Import → Plan → Adjust Code → Repeat
`

---

# Lab Architecture

Existing infrastructure:

```
Azure Subscription
│
├── Resource Group (existing)
│   └── Virtual Network (existing)
│
└── Storage Account (existing)
    └── Blob Container (used for Terraform backend)
```

After the lab:

* Terraform will **manage the RG and VNet**
* Terraform state will be stored **remotely in Azure Storage**

---

# Step 1 — Create Terraform Project Structure

Create a new folder for this lab.

Example structure:

```
terraform-import-lab
│
├── main.tf
├── variables.tf
├── providers.tf
└── backend.tf
```

Follow the **Terraform best practices** you learned in previous labs:

* Proper file separation
* Variables with descriptions and types
* Clear naming conventions

---

# Step 2 — Configure the Azure Provider

Create the Azure provider configuration.

Example:

```
provider "azurerm" {
  features {}
}
```

Run:

```
terraform init
```

---

# Step 3 — Write Code for the Existing Resource Group

Before importing a resource, **Terraform requires a matching resource block** in the code.

Create a resource block describing the **existing Resource Group**.

Example structure:

```
resource "azurerm_resource_group" "lab_rg" {
  name     = var.resource_group_name
  location = var.location
}
```

Define the variables in `variables.tf`.

At this stage **Terraform does not yet manage the resource**.

---

# Step 4 — Import the Resource Group

Use the Terraform import command:

```
terraform import azurerm_resource_group.lab_rg <RESOURCE_ID>
```
**OBS:** the RESOURCE_ID can be obtained at Azure Portal, on the resource's overview page → JSON View.

<img width="1338" height="360" alt="image" src="https://github.com/user-attachments/assets/65a26cae-ca22-45ab-9de0-abac758a4e52" />

<img width="745" height="145" alt="image" src="https://github.com/user-attachments/assets/3944ee68-2a96-4378-9707-44a6dd22be91" />

Example:

```
terraform import azurerm_resource_group.lab_rg /subscriptions/<SUB_ID>/resourceGroups/<RG_NAME>
```
<img width="1055" height="206" alt="image" src="https://github.com/user-attachments/assets/cd722401-581c-4fe8-9d18-3d1c6f17c503" />


After importing, run:

```
terraform plan
```
Terraform will compare the **existing infrastructure** with your **Terraform code**.

If Terraform proposes changes, adjust your code accordingly.

<img width="1021" height="302" alt="image" src="https://github.com/user-attachments/assets/8eb5eabd-fe83-4bda-bda3-3ab852cb1a66" />


Repeat the cycle:

`
Import → Plan → Adjust Code → Repeat
`

until the plan shows:

`
No changes. Your infrastructure matches the configuration.
`

---

# Step 5 — Write Code for the Existing Virtual Network

Now repeat the same process for a **Virtual Network**.

Add a resource block similar to:

```
resource "azurerm_virtual_network" "lab_vnet" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name

  address_space = [
    var.address_space
  ]
}
```

Define all necessary variables.

---

# Step 6 — Import the Virtual Network

Repeat the process to import the existing VNet:

```
terraform import azurerm_virtual_network.lab_vnet <RESOURCE_ID>
```

Example:

```
terraform import azurerm_virtual_network.lab_vnet /subscriptions/<SUB_ID>/resourceGroups/<RG_NAME>/providers/Microsoft.Network/virtualNetworks/<VNET_NAME>
```

Run:

```
terraform plan
```

Adjust your Terraform code until the plan shows **no differences**.

<img width="1034" height="138" alt="image" src="https://github.com/user-attachments/assets/c6182fa7-d297-46b4-8af3-07f39e6d8d9c" />

---

# Step 7 — Configure the Remote Backend

Terraform is currently storing state **locally**.

Now you will configure a **remote backend using Azure Storage**.

Create a `backend.tf` file.

Example structure:

```
terraform {

  backend "azurerm" {

    resource_group_name  = "existing-backend-rg"
    storage_account_name = "existingstorageaccount"
    container_name       = "tfstate"

    key = "student-<yourname>.tfstate"

  }

}
```

Each student must use a **unique key** to avoid overwriting another student's state.

Example:

```
key = "terraform-lab3-pedro.tfstate"
```

---

# Step 8 — Migrate Terraform State

Initialize Terraform again and migrate the state:

```
terraform init -migrate-state
```

Terraform will ask confirmation to move the state from **local backend → Azure Storage backend**.

Confirm with:

```
yes
```

After migration, Terraform state will be stored in **Azure Blob Storage**.

---

<img width="699" height="498" alt="image" src="https://github.com/user-attachments/assets/1cdc2eb4-2f53-4ca7-baf8-a7210e897ece" />


# Step 9 — Validate the Configuration

Run:

```
terraform plan
```

Terraform should report:

```
No changes. Infrastructure is up-to-date.
```

You can also verify the **Terraform state file** inside the Azure Storage container.

---

# Best Practices Reminder

While completing this lab, remember to follow good Terraform practices:

* Declare **all variables** with:

  * type
  * description
  * default (when appropriate)
* Use clear **file organization**
* Avoid hardcoded values when variables are more appropriate
* Validate changes with `terraform plan`

---

# Wrap-Up

In this lab you learned how to **adopt existing infrastructure into Terraform management**.

You practiced:

* Importing Azure resources into Terraform state
* Iteratively refining Terraform code
* Configuring a **remote backend**
* Migrating Terraform state to Azure Storage

These techniques are essential when introducing **Infrastructure as Code into environments where resources already exist**.

The lab files and reference examples are available in the repository if you need guidance during the exercise.
