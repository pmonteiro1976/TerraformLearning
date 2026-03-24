
# Lab 5 : Terraform CI/CD Deployment using GitHub Actions

## Lab Overview

In this lab you will learn how to automate Terraform infrastructure deployments using **GitHub Actions CI/CD pipelines**.

Instead of manually running Terraform commands from your local machine, Terraform will be executed automatically when code changes are pushed to your GitHub repository.

You will:

*   Write Terraform configuration files for Azure
*   Configure authentication using a **Service Principal**
*   Store credentials securely using **GitHub Secrets**
*   Create a **GitHub Actions pipeline** to run Terraform
*   Observe **Continuous Integration (CI)** and **Continuous Deployment (CD)** in action

By the end of this lab, pushing Terraform code to GitHub will automatically trigger an infrastructure deployment.

* * *

## Lab Architecture

Each student will deploy **their own infrastructure** in one Azure region.

Resources created:

*   Azure Resource Group
*   Azure Storage Account
*   Azure Blob Container

```
GitHub Repository
        │
        ▼
GitHub Actions Workflow
        │
        ▼
Terraform Pipeline
(init → plan → apply)
        │
        ▼
Azure Infrastructure
   ├ Storage Account
   └ Blob Container
```

## Lab Objectives

After completing this lab you will be able to:

*   Understand **GitHub and GitHub Actions workflows**
*   Separate **CI and CD stages**
*   Deploy Terraform infrastructure automatically
*   Authenticate Azure deployments using **Service Principals**
*   Store secrets securely using **GitHub Secrets**
*   Trigger infrastructure deployment through **Git commits**

* * *

## Step 1 : Introduction to GitHub and GitHub Actions

## What is GitHub?

GitHub is a platform used for:

*   Source code hosting
*   Version control
*   Collaboration
*   Automation workflows

GitHub repositories store code and allow teams to track changes using **Git**.

* * *

## What is GitHub Actions?

GitHub Actions is a **CI/CD platform built into GitHub** that allows you to automate workflows.

Workflows are triggered by repository events such as:

*   Push
*   Pull Request
*   Manual trigger

Workflows are written in **YAML** and stored inside:

`.github/workflows/`


<img width="1355" height="635" alt="image" src="https://github.com/user-attachments/assets/2062943d-a6c5-44fa-850c-bf4a0d03ac69" />


* * *

## Step 2 : Create and clone the Repository

On your Github account, create a new Repo for our project:

<img width="80%" alt="image" src="https://github.com/user-attachments/assets/94e82ed3-9aa6-4bf2-ae6d-4e33295938c9" />


Then locally, clone the lab repository.

```
git clone https://github.com/YOUR-ACCOUNT\REPOSITORY\URL
```
<img width="60%" alt="image" src="https://github.com/user-attachments/assets/d1e50328-a147-4cd4-92b1-3723093e4630" />

Navigate to the folder:
```
cd terraform\github-lab
```
* * *

## Step 3 : Project Structure

Create the following structure:
```
terraform
 │
 ├ backend.tf
 ├ main.tf
 ├ variables.tf
 ├ outputs.tf
 ├ providers.tf
 └ terraform.tfvars
```

* * *

## Step 4 : Configure the Remote Backend

You should continue using the **remote backend implemented in the previous lab**.

Create `backend.tf`.

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "existing-backend-rg"
    storage_account_name = "existingstorageaccount"
    container_name       = "tfstate"
    key = "student-<yourname>.tfstate"
  }
}
```


This ensures the Terraform state file is stored remotely.

* * *

## Step 5 : Configure the Azure Provider

Create `providers.tf`.

```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {}
}
```

* * *

## Step 6 : Define Variables

Create `variables.tf`.

```hcl
variable "location" {
  description = "Azure region where resources will be deployed"
  type        = string
}

variable "resource_group_name" {
  description = "Resource Group name"
  type        = string
}

variable "storage_account_name" {
  description = "Storage Account name (must be globally unique)"
  type        = string
}

variable "container_name" {
  description = "Blob container name"
  type        = string
  default     = "lab-container"
}
```

* * *

## Step 7 : Define Infrastructure Resources

Create `main.tf` and add the following resources code to:

```hcl
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_storage_account" "storage" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "container" {
  name                  = var.container_name
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}
```

* * *

## Step 8 : Define Outputs

Create `outputs.tf`.

```hcl
output "storage_account_name" {
  value = azurerm_storage_account.storage.name
}

output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}
```

* * *

## Step 9 : Define Variable Values

Create `terraform.tfvars`.

Each student should deploy to **one of the following regions**:

*   westeurope
*   northeurope
*   norwayeast
*   switzerlandnorth
*   canadacentral

Example:

```hcl
location             = "westeurope"
resource_group_name  = "rg-lab5-student1"
storage_account_name = "stlab5student01"
container_name       = "lab-container"
```

* * *

## Step 10 : Configure Azure Authentication

Terraform will authenticate using a **Service Principal**.

The credentials will be stored as **GitHub Secrets**.

Navigate to:

`Repository → Settings → Secrets → Actions`

Create a secret named:

`AZURE_CREDENTIALS`

**OBS:** ask your instructor about the Service Principal credentials for this lab.

Paste the Service Principal JSON credentials.

Example:

```json
{
  "clientId": "...",
  "clientSecret": "...",
  "subscriptionId": "...",
  "tenantId": "..."
}
```

<img width="60%" alt="image" src="https://github.com/user-attachments/assets/3450ec17-aa25-4cd1-92a2-ceb0abf3903c" />

<img width="60%" alt="image" src="https://github.com/user-attachments/assets/2facb068-f019-4f2d-9cc8-c86472d2ac71" />

* * *

## Step 11 : Create the GitHub Actions Workflow

Create the file:

`.github/workflows/terraform-pipeline.yml`

* * *

## CI Job - Terraform Plan on Pull Request

This job performs **Continuous Integration validation**.

```yaml
name: Terraform CI/CD Pipeline

on:
  pull_request:
    branches: [ main ]
  push:
    branches: [ main ]
  workflow_dispatch:

jobs:

  terraform_ci:
    name: Terraform Plan (CI)
    if: github.event_name == 'pull_request'
    runs-on: ubuntu-latest

    defaults:
      run:
        working-directory: ./terraform

    steps:

      - name: Checkout
        uses: actions/checkout@v4

      - name: Azure Login
        uses: azure/login@v2
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3

      - name: Terraform Init
        run: terraform init

      - name: Terraform Format
        run: terraform fmt -check

      - name: Terraform Validate
        run: terraform validate

      - name: Terraform Plan
        run: terraform plan -no-color
```

This job runs when a **Pull Request is created**, ensuring infrastructure changes are validated before deployment.

* * *

## CD Job - Terraform Apply with Manual Approval

This job performs **Continuous Deployment**.

```yaml
  terraform_cd:

    name: Terraform Apply (CD)

    if: github.event_name == 'pull_request'

    needs: terraform_ci

    runs-on: ubuntu-latest

    environment:
      name: production

    defaults:
      run:
        working-directory: ./terraform

    steps:

      - name: Checkout
        uses: actions/checkout@v4

      - name: Azure Login
        uses: azure/login@v2
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3

      - name: Terraform Init
        run: terraform init

      - name: Terraform Plan
        run: terraform plan -out=tfplan

      - name: Terraform Apply
        run: terraform apply -auto-approve tfplan
```

**OBS:** Your final folder structure should be like:

<img width="40%" alt="image" src="https://github.com/user-attachments/assets/39e88fec-2f88-4d5b-9d85-db446e620a35" />


* * *

## Step 12 : Configure Environment Approval

Navigate to:

`Repository Settings → Environments`

Create an environment called:

`production`

Enable **Required reviewers**.

This forces **manual approval before the CD job runs**.

* * *

<img width="70%" alt="image" src="https://github.com/user-attachments/assets/6ca8a3ef-b3ae-43b7-950e-6e8350ec4eb4" />


* * *

## Step 13 : Trigger the Pipeline

Create a new branch and commit your Terraform code.

```bash
git checkout -b lab5  
git add .  
git commit -m "Add Terraform CI/CD pipeline"  
git push origin lab5
```

Create a **Pull Request**.

The **CI job will run automatically** and show the Terraform plan.

<img width="1197" height="513" alt="image" src="https://github.com/user-attachments/assets/6d58088c-5ccf-438a-b3ea-2bec92d8af91" />


Click on the "Terraform Plan (CI)" Stage to check the steps executed by the pipeline as they were defined on the pipeline yaml file:

<img width="652" height="850" alt="image" src="https://github.com/user-attachments/assets/5914c4d8-214f-4007-b102-71570d0fc6f7" />

* * *

## Step 14 : Deploy Infrastructure

Merge the Pull Request into main.

The CD pipeline will:

1.  Run Terraform Plan
2.  Wait for **manual approval**
3.  Execute Terraform Apply
4.  Deploy the infrastructure

<img width="1538" height="514" alt="image" src="https://github.com/user-attachments/assets/d6d8f172-df76-4da1-8c61-3cd34d38c7aa" />

<img width="998" height="579" alt="image" src="https://github.com/user-attachments/assets/1d22bf5a-2735-4d7e-bc66-d2cd44136e1e" />

<img width="1082" height="859" alt="image" src="https://github.com/user-attachments/assets/ae27460f-8256-4e4c-abef-439c8266e69e" />


* * *

## Expected Result

Each student deployment will create:

| **Resource** | **Description** |
|-------------|----------------|
| Resource Group | Logical container for resources |
| Storage Account | Azure storage service |
| Blob Container | Storage container for blobs |

* * *

## CI/CD Flow Demonstration

```
Developer Push
      │
      ▼
Pull Request
      │
      ▼
CI Pipeline
(terraform plan)
      │
      ▼
Merge to Main
      │
      ▼
Manual Approval
      │
      ▼
CD Pipeline
(terraform apply)
      │
      ▼
Azure Infrastructure Deployment
```


* * *

## Lab Wrap-Up

In this lab you learned how to:

*   Use **GitHub Actions to automate Terraform deployments**
*   Separate stages: **CI (validation) and CD (deployment)**
*   Authenticate Terraform using **Service Principals**
*   Secure credentials using **GitHub Secrets**
*   Protect production environments with **manual approvals**

This workflow represents a **common DevOps pattern used by cloud engineering teams** to manage infrastructure safely and consistently.
