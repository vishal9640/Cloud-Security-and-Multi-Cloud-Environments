output "public_ip" {
  value = azurerm_linux_virtual_machine.wireguard_azure.public_ip_address
}
