provider "azurerm" {
  features {}
  subscription_id ="25bcf5d0-16ab-458b-b03a-0d97376069e0"
}

# Create Azure Resource Group
resource "azurerm_resource_group" "wireguard_rg" {
  name     = "WireGuardRG"
  location = "West Europe"
}

# Create Azure Virtual Network (VNet)
resource "azurerm_virtual_network" "wireguard_vnet" {
  name                = "wireguard-vnet"
  resource_group_name = azurerm_resource_group.wireguard_rg.name
  location            = azurerm_resource_group.wireguard_rg.location
  address_space       = ["10.1.0.0/16"]
}
#Adding a Public IP resource 
resource "azurerm_public_ip" "wireguard_public_ip" {
  name                = "wireguard-public-ip"
  resource_group_name = azurerm_resource_group.wireguard_rg.name
  location            = azurerm_resource_group.wireguard_rg.location
  allocation_method   = "Static"
}

# Create a Subnet for WireGuard
resource "azurerm_subnet" "wireguard_subnet" {
  name                 = "wireguard-subnet"
  resource_group_name  = azurerm_resource_group.wireguard_rg.name
  virtual_network_name = azurerm_virtual_network.wireguard_vnet.name
  address_prefixes     = ["10.1.1.0/24"]
}

# Create Network Security Group (NSG) for WireGuard
resource "azurerm_network_security_group" "wireguard_sg" {
  name                = "wireguard-sg"
  location            = azurerm_resource_group.wireguard_rg.location
  resource_group_name = azurerm_resource_group.wireguard_rg.name
}

# Allow WireGuard (UDP Port 51820) in NSG
resource "azurerm_network_security_rule" "wireguard_rule" {
  name                        = "allow-wireguard"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Udp"
  source_port_range           = "*"
  destination_port_range      = "51820"
  source_address_prefix       = "172.31.0.0/20"  # Change to AWS Private IP Range
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.wireguard_sg.name
  resource_group_name         = azurerm_resource_group.wireguard_rg.name
}

resource "azurerm_network_security_rule" "allow_ssh" {
  name                        = "allow-ssh"
  priority                    = 110  # Must be higher than WireGuard (100)
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "0.0.0.0/0"  # Allow SSH from anywhere
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.wireguard_sg.name
  resource_group_name         = azurerm_resource_group.wireguard_rg.name
}

# Create Network Interface (NIC) for WireGuard VM
resource "azurerm_network_interface" "wireguard_nic" {
  name                = "wireguard-nic"
  location            = azurerm_resource_group.wireguard_rg.location
  resource_group_name = azurerm_resource_group.wireguard_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.wireguard_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.wireguard_public_ip.id
  }
}

# Attach Network Security Group (NSG) to the Network Interface (NIC)
resource "azurerm_network_interface_security_group_association" "wireguard_nic_sg" {
  network_interface_id      = azurerm_network_interface.wireguard_nic.id
  network_security_group_id = azurerm_network_security_group.wireguard_sg.id
}

# Deploy the Azure Linux Virtual Machine
resource "azurerm_linux_virtual_machine" "wireguard_azure" {
  name                = "WireGuardAzure"
  resource_group_name = azurerm_resource_group.wireguard_rg.name
  location            = azurerm_resource_group.wireguard_rg.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  disable_password_authentication = true 
  admin_ssh_key {
    username   = "adminuser"
    public_key = file("D:\\Masters In CS\\Subjects\\Spring 2025\\Cloud-Security-and-Multi-Cloud-Environments\\main\\azure\\LinuxServer_key.pub")  # ✅ Ensure this file exists
  }

  network_interface_ids = [azurerm_network_interface.wireguard_nic.id]  # ✅ Now it exists!
  
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}
