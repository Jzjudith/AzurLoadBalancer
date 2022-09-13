resource "azurerm_resource_group" "main" {
  name     = "devlab-test-lb-rg"
  location = "East US2"
}

resource "azurerm_availability_set" "main" {
  name                = "main-aset"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = {
    environment = "Devlopment"
  }
}

resource "azurerm_virtual_network" "main" {
  name                = "dev_test_vnet"
  resource_group_name = azurerm_resource_group.main.name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
}


# Create Subnets
resource "azurerm_subnet" "main" {
  name                 = "lbsubnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "nic" {
  name                = "jmp_pip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
}


#create network interface
resource "azurerm_network_interface" "nic" {
  name                = "jmpbx-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "jmpbx-ipconfig"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.nic.id
  }
}


resource "azurerm_network_interface" "nic1" {
  name                = "linux-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "nic-ipconfig1"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"

  }
}

resource "azurerm_network_interface" "nic2" {
  name                = "windows-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "nic-ipconfig2"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"

  }
}

resource "azurerm_linux_virtual_machine" "jmpbx" {
  name                  = "jumpbox"
  resource_group_name   = azurerm_resource_group.main.name
  location              = azurerm_resource_group.main.location
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

}

resource "azurerm_linux_virtual_machine" "main" {
  name                            = "devlinvm"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  size                            = "Standard_B1s"
  admin_username                  = "devlab"
  admin_password                  = "Password123"
  availability_set_id             = azurerm_availability_set.main.id
  network_interface_ids           = [azurerm_network_interface.nic1.id, ]
  disable_password_authentication = false
  user_data                       = filebase64("${path.module}/scripts/script1.sh")

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
}




resource "azurerm_linux_virtual_machine" "main2" {
  name                            = "devlinvm2"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  size                            = "Standard_B1s"
  admin_username                  = "devlab"
  admin_password                  = "Password123"
  availability_set_id             = azurerm_availability_set.main.id
  network_interface_ids           = [azurerm_network_interface.nic2.id, ]
  disable_password_authentication = false
  user_data                       = filebase64("${path.module}/scripts/script2.sh")

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

}
