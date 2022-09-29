output "pip1" {
  value = azurerm_public_ip.main[0].ip_address
}

output "pip2" {
  value = azurerm_public_ip.main[1].ip_address
}