# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  resource_provider_registrations = "none"
  features {}
  subscription_id = ""
}

# Deploy Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "rg_otavio"
  location = "Brazil South"
}

# Deploy VNET (Virtual Network)
resource "azurerm_virtual_network" "vnet_otavio" {
  name                = "vnet-otavio"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.50.0.0/16"]
}

# Deploy Subnet
resource "azurerm_subnet" "subn_otavio" {
  name                 = "sub-otavio"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_otavio.name
  address_prefixes     = ["10.50.1.0/24"]
}

# Deploy NSG (Network Security Group)
resource "azurerm_network_security_group" "nsg_otavio" {
  name                = "nsg-otavio"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "Allow-RDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "10.50.1.0/24"
  }
}

# Associar NSG Subnet
resource "azurerm_subnet_network_security_group_association" "nsg_otavio" {
  subnet_id                 = azurerm_subnet.subn_otavio.id
  network_security_group_id = azurerm_network_security_group.nsg_otavio.id
}

# Deploy Public IP
resource "azurerm_public_ip" "ip_otavio" {
  name                = "ip-otavio"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
}

# Deploy NIC
resource "azurerm_network_interface" "vnic01" {
  name                = "nic-vm-win01"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subn_otavio.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ip_otavio.id
  }
}

# Deploy VM
resource "azurerm_windows_virtual_machine" "vm_otavio" {
  name                = "vm-otavio"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B2S"
  admin_username      = "otavio"
  admin_password      = "XPtbr1993"
  network_interface_ids = [
    azurerm_network_interface.vnic01.id,
  ]

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
}

