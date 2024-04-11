output "resource_group_name" {
    value = azurerm_resource_group.rg.name
  
}

output "public_ip_address" {
    value = azurerm_windows_virtual_machine.case_vm.public_ip_addresses
}

output "admin_password" {
    value = azurerm_windows_virtual_machine.case_vm.admin_password
    sensitive = true
  
}