# creating the resource group using the random name

resource "azurerm_resource_group" "rg" {
  location = var.azurerm_resource_group_location
  name = "${random_pet.prefix.id}-rg"
}

# creating the virtual network

resource "azurerm_virtual_network" "case_network" {
  name = "${random_pet.prefix.id}-vnet"
  address_space = [ "10.0.0.0/16" ]
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name  
}

# creating a subnet 

resource "azurerm_subnet" "case_subnet" {
  name = "${random_pet.prefix.id}-subnet"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.case_network.name
  address_prefixes = ["10.0.1.0/24"]
    
}

# create the public Ip address

resource "azurerm_public_ip" "case_public_ip" {
  name = "${random_pet.prefix.id}-public-ip"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method = "Dynamic"
  
}

# creating the network security and rules

resource "azurerm_network_security_group" "case_nsg" {
  name = "${random_pet.prefix.id}-nsg"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name = "RDP"
    priority = 1000
    direction = "Inbound"
    access = "Allow"
    protocol = "*"
    source_port_range = "*"
    destination_port_range = "3389"
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name = "web"
    priority = 1001
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "80"
    source_address_prefix = "*"
    destination_address_prefix = "*"

  }
  
}


# creating the network interface

resource "azurerm_network_interface" "case_interface_nic" {
  name = "${random_pet.prefix.id}-nic"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name


  ip_configuration {
    name = "my_nw-interface_configuration"
    subnet_id = azurerm_subnet.case_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.case_public_ip.id
  }
  
}

# connect the security group to the network interface

resource "azurerm_network_interface_security_group_association" "case-nw-sg" {
  network_interface_id = azurerm_network_interface.case_interface_nic.id
  network_security_group_id = azurerm_network_security_group.case_nsg.id

}

# create the storage account for boot diagnostics

resource "azurerm_storage_account" "case-storage" {
  name = "diag${random_id.random_id.hex}"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  account_tier =  "Standard"
  account_replication_type = "LRS"
  
}

# create virtual machine

resource "azurerm_windows_virtual_machine" "case_vm" {
  name = "${var.prefix}-vm"
  admin_username = "azureuser"
  admin_password = random_password.password.result
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.case_interface_nic.id]
  size = "standard_DS1_v2"

  os_disk {
    name = "myosdisk"
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftwindowsServer"
    offer = "windowsServer"
    sku = "2022-datacenter-azure-edition"
    version = "latest"
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.case-storage.primary_blob_endpoint
  }

}

# install IIS web server to the virtual machine

resource "azurerm_virtual_machine_extension" "case-server-install" {
  name = "${random_pet.prefix.id}-wsi"
  virtual_machine_id = azurerm_windows_virtual_machine.case_vm.id
  publisher = "Microsoft.compute"
  type = "customScriptExtension"
  type_handler_version = "1.8"
  auto_upgrade_minor_version = true

  settings =  <<SETTINGS
  {
    "commandToExecute" : "powershell -ExecutionPolicy unrestricted Install-WindowsFeature -Name Web-Server -IncludeAllsubFeature -IncludeManagementTools"
  }
 SETTINGS

}

# generate random text for a unique storgae account name

resource "random_id" "random_id" {
  keepers = {
    # generate a new ID only when a new resource group is defined
    resource_group = azurerm_resource_group.rg.name
  }

  byte_length = 8
}

resource "random_password" "password" {
  length = 20
  min_upper = 1
  min_lower = 1
  min_numeric = 1
  min_special = 1
  special = true
  
}

resource "random_pet" "prefix" {
  prefix = var.prefix
  length = 1
  
}

