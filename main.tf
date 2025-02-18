terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.7.0"
    }
  }

  # Update this block with the location of your terraform state file
  backend "azurerm" {
    resource_group_name  = "rg-tf-backend"
    storage_account_name = "sbwstaccounttfbackend"
    container_name       = "terraform-state-github-actions"
    key                  = "terraformgithub-actions.tfstate"
    use_oidc             = true
  }
}

provider "azurerm" {
  features {}
  use_oidc = true
}

# Define any Azure resources to be created here. A simple resource group is shown here as a minimal example.
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}
resource "random_id" "storage_account" {
  byte_length = 8
}
# Creating an Azure Storage Account with public access disabled
resource "azurerm_storage_account" "my_storage_account" {
  name                    = "tfsta${lower(random_id.storage_account.hex)}"
  resource_group_name     = "${azurerm_resource_group.rg.name}"
  account_tier            = "Standard"
  account_replication_type = "LRS"
  # This setting allows public access to the storage account, flagged by tfsec
  access_tier             = "Hot"
  enable_public_network_access = false
}
