terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.0.0"
    }
  }
}

# configure the Microsoft Azure provider

provider "azurerm" {
  features {

  }

}

# create a resource group

resource "azurerm_resource_group" "Testsource" {
  location = "eastus"
  name     = "Testsource"

}