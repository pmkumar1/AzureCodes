variable "azurerm_resource_group_location" {
    default = "westus2"
    description = "location of the resources and resource group"
}

variable "prefix" {
    type = string
    default = "win-vm-iis"
    description = "prefix of the resource names"
  
}