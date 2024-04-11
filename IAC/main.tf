# creating the resource group

resource "azurerm_resource_group" "CDX-platform" {
  name     = "CDX-platform"
  location = "Eastus"

}