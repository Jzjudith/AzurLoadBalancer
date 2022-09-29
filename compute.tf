# vitual machines
resource "azurerm_linux_virtual_machine" "jmpbx" {
  name                  = "jumpbox"
  resource_group_name   = var.resource_group
  location              = var.location
  size                  = "Standard_B1s"
  admin_username        = "devlab"
  admin_password        = "Password123"
  network_interface_ids = [azurerm_network_interface.nic.id, ]

  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  
  depends_on = [
    azurerm_network_interface.main
  ]

}

resource "azurerm_linux_virtual_machine" "main" {
  count                 = 2
  name                  = "devlinvm-${count.index}"
  resource_group_name   = var.resource_group
  location              = var.location
  size                  = "Standard_B1s"
  admin_username        = "devlab"
  admin_password        = "Password123"
  availability_set_id   = azurerm_availability_set.main.id
  network_interface_ids = [element([for nic in azurerm_network_interface.main : nic.id], count.index), ]
  user_data             = filebase64("${path.module}/scripts/script.sh")

  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  depends_on = [
    azurerm_network_interface.main
  ]

}




