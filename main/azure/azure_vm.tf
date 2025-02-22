provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "wireguard_rg" {
  name     = "WireGuardRG"
  location = "West Europe"
}

resource "azurerm_virtual_network" "wireguard_vnet" {
  name                = "wireguard-vnet"
  resource_group_name = azurerm_resource_group.wireguard_rg.name
  location            = azurerm_resource_group.wireguard_rg.location
  address_space       = ["40.68.160.242"]
}

resource "azurerm_network_security_group" "wireguard_sg" {
  name                = "wireguard-sg"
  location            = azurerm_resource_group.wireguard_rg.location
  resource_group_name = azurerm_resource_group.wireguard_rg.name
}

resource "azurerm_network_security_rule" "wireguard_rule" {
  name                        = "allow-wireguard"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Udp"
  source_port_range           = "*"
  destination_port_range      = "51820"
  source_address_prefix       = "13.60.6.126"  # Change to AWS IP later
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.wireguard_sg.name
  resource_group_name         = azurerm_resource_group.wireguard_rg.name
}

resource "azurerm_linux_virtual_machine" "wireguard_azure" {
  name                = "WireGuardAzure"
  resource_group_name = azurerm_resource_group.wireguard_rg.name
  location            = azurerm_resource_group.wireguard_rg.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"

  network_interface_ids = [azurerm_network_interface.wireguard_nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}
