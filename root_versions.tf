terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate2"
    storage_account_name = "tfstate216581"
    container_name       = "tfstate2"
    key                  = "terraform.tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "< 4.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}