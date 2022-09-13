resource "azurerm_public_ip" "main" {
  name                = "Loadbpip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "main2" {
  name                = "outboundip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "main" {
  name                = "devlabtestLB"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"
  sku_tier            = "Regional"

  frontend_ip_configuration {
    name                 = "FrndPip"
    public_ip_address_id = azurerm_public_ip.main.id

  }
  frontend_ip_configuration {
    name                 = "outboundip"
    public_ip_address_id = azurerm_public_ip.main2.id

  }
}

resource "azurerm_lb_backend_address_pool" "main" {
  loadbalancer_id = azurerm_lb.main.id
  name            = "BkndAddPl"
}


resource "azurerm_lb_outbound_rule" "test" {
  loadbalancer_id         = azurerm_lb.main.id
  name                    = "outboundRule"
  protocol                = "Tcp"
  backend_address_pool_id = azurerm_lb_backend_address_pool.main.id
  frontend_ip_configuration {
    name = "outboundip"
  }

}

resource "azurerm_lb_probe" "main" {
  loadbalancer_id = azurerm_lb.main.id
  name            = "running-probe"
  port            = 80
}

resource "azurerm_lb_rule" "main" {
  loadbalancer_id                = azurerm_lb.main.id
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "FrndPip"
  backend_address_pool_ids = [ azurerm_lb_backend_address_pool.main.id]
  probe_id = azurerm_lb_probe.main.id

}




resource "azurerm_network_interface_backend_address_pool_association" "main" {
  network_interface_id    = azurerm_network_interface.nic1.id
  ip_configuration_name   = "nic-ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.main.id
}

resource "azurerm_network_interface_backend_address_pool_association" "main2" {
  network_interface_id    = azurerm_network_interface.nic2.id
  ip_configuration_name   = "nic-ipconfig2"
  backend_address_pool_id = azurerm_lb_backend_address_pool.main.id
}