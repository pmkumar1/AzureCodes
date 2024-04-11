# Azure provider source and version

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Configuring the Microsoft Azure Provider

provider "azurerm" {

  features {}
}

