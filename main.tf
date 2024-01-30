terraform {
    required_providers {
        azurerm = {
            source  = "hashicorp/azurerm"
            version = ">3.0.0"
        }
    }
}

provider "azurerm" {
  features {}
    subscription_id  = "f9e5318c-bdd7-47c4-b13c-76ce35493851"
    client_id        = "096c15a6-45d7-45be-ae33-058c1d08d615"
    client_secret    = "IRn8Q~efKG9qgC1FF1JHCpiwK3NzNpjpWn6ltbDn"
    tenant_id        = "0167f13c-97c2-4249-a97f-0258217e4ea4"
}

# terraform {
#   backend "azurerm" {
#     storage_account_name = "manikantatfsa01"
#     container_name       = "tfstorage01"
#     key                  = "DEV/webserver_VM"
#     access_key           = "Q5iOxprf5JwtitnsHVvrkb++65lORBE7LuBkQz4VC2A1ToLKzQRzKVCMHhed2xRH5fodQvVyCTNo+AStm2NDWw=="
#   }
# }

resource "azurerm_resource_group" "RG" {
  name          = "${var.rg_name}-RG01"
  location      = "${var.location}"
}

# resource "azurerm_storage_account" "sa01" {
#     name                     = "${var.storageaccount}"
#     resource_group_name      = "${azurerm_resource_group.RG.name}"
#     location                 = "${azurerm_resource_group.RG.location}"
#     account_tier             = "Standard"
#     account_replication_type = "LRS" 
# }

resource "azurerm_virtual_network" "VNET" {
    name                = "${var.prefix}-VNET01"
    resource_group_name = "${azurerm_resource_group.RG.name}"
    location            = "${azurerm_resource_group.RG.location}"
    address_space       = [ "${var.vnet_cidr_prefix}" ]
}

resource "azurerm_subnet" "subnet" {
    name                 = "${var.prefix}-Subnet01"
    resource_group_name  = "${azurerm_resource_group.RG.name}"
    virtual_network_name = "${azurerm_virtual_network.VNET.name}"
    address_prefixes     = [ "${var.subnet_cidr_prefix}" ]
}

resource "azurerm_public_ip" "MyVMPIP01" {
    name                 = "${var.prefix}-PIP01"
    resource_group_name  = "${azurerm_resource_group.RG.name}"
    location             = "${azurerm_resource_group.RG.location}"
    allocation_method    = "Dynamic"  
}

resource "azurerm_network_interface" "mynic01" {
    name                 = "${var.prefix}-nic01"
    resource_group_name  = "${azurerm_resource_group.RG.name}"
    location             = "${azurerm_resource_group.RG.location}"

    ip_configuration {
      name                          = "internal"
      subnet_id                     = "${azurerm_subnet.subnet.id}" 
      private_ip_address_allocation = "Dynamic"
      public_ip_address_id          = "${azurerm_public_ip.MyVMPIP01.id}"  
    }  
}

resource "azurerm_linux_virtual_machine" "myvm01" {
   name                  = "${var.prefix}-VM01"
   resource_group_name   = "${azurerm_resource_group.RG.name}"
   location              = "${azurerm_resource_group.RG.location}"
   size                  = "${var.vm_size}"
   admin_username        = "adminuser"
   network_interface_ids = [
              azurerm_network_interface.mynic01.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}


