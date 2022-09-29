# resource group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group
  location = var.location
}

# availability set
resource "azurerm_availability_set" "main" {
  name                = var.availability_set
  location            = var.location
  resource_group_name = var.resource_group

  tags = {
    environment = "Devlopment"
  }
  depends_on = [
    azurerm_resource_group.main
  ]
}

# virtual network
resource "azurerm_virtual_network" "main" {
  name                = var.virtual_network
  location            = var.location
  resource_group_name = var.resource_group
  address_space       = ["10.0.0.0/16"]
  depends_on = [
    azurerm_resource_group.main
  ]
}


# subnets
resource "azurerm_subnet" "main" {
  name                 = var.subnet
  resource_group_name  = var.resource_group
  virtual_network_name = var.virtual_network
  address_prefixes     = ["10.0.1.0/24"]
  depends_on = [
    azurerm_virtual_network.main
  ]
}

# public ip address
resource "azurerm_public_ip" "pip" {
  name                = var.public_ip
  location            = var.location
  resource_group_name = var.resource_group
  allocation_method   = "Static"
  depends_on = [
    azurerm_resource_group.main
  ]
}


# network interfaces
resource "azurerm_network_interface" "nic" {
  name                = "jmpbx-nic"
  location            = var.location
  resource_group_name = var.resource_group

  ip_configuration {
    name                          = "jmpbx-ipconfig"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
  depends_on = [
   azurerm_subnet.main
  ]
}


resource "azurerm_network_interface" "main" {
  count               = 2
  name                = "vm-nic-${count.index}"
  location            = var.location
  resource_group_name = var.resource_group

  ip_configuration {
    name                          = "ip-conf-nic-${count.index}"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"

  }
 depends_on = [
   azurerm_subnet.main
  ]
}

