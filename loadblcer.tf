# loadbalancer public ip
resource "azurerm_public_ip" "main" {
  count               = 2
  name                = "Loadbpip-${count.index}"
  location            = var.location
  resource_group_name = var.resource_group
  allocation_method   = "Static"
  sku                 = "Standard"
  depends_on = [
    azurerm_resource_group.main
  ]
}


# load balancer
resource "azurerm_lb" "main" {
  name                = "devlabtestLB"
  location            = var.location
  resource_group_name = var.resource_group
  sku                 = "Standard"
  sku_tier            = "Regional"

  frontend_ip_configuration {
    name                 = "FrndPip"
    public_ip_address_id = azurerm_public_ip.main[0].id

  }
  frontend_ip_configuration {
    name                 = "outboundip"
    public_ip_address_id = azurerm_public_ip.main[1].id

  }
  depends_on = [
    azurerm_public_ip.main
  ]
}

# Load balancer backend address pool
resource "azurerm_lb_backend_address_pool" "main" {
  loadbalancer_id = azurerm_lb.main.id
  name            = "BkndAddPl"
}

# Load balancer outbound rule
resource "azurerm_lb_outbound_rule" "test" {
  loadbalancer_id         = azurerm_lb.main.id
  name                    = "outboundRule"
  protocol                = "Tcp"
  backend_address_pool_id = azurerm_lb_backend_address_pool.main.id
  frontend_ip_configuration {
    name = "outboundip"
  }

}

# Load balancer probe
resource "azurerm_lb_probe" "main" {
  loadbalancer_id = azurerm_lb.main.id
  name            = "running-probe"
  port            = 80
}

# Load balancer rule
resource "azurerm_lb_rule" "main" {
  loadbalancer_id                = azurerm_lb.main.id
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "FrndPip"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.main.id]
  probe_id                       = azurerm_lb_probe.main.id

}




resource "azurerm_network_interface_backend_address_pool_association" "main" {
  network_interface_id    = azurerm_network_interface.main[0].id
  ip_configuration_name   = "ip-conf-nic-0"
  backend_address_pool_id = azurerm_lb_backend_address_pool.main.id
  depends_on = [
    azurerm_network_interface.main
  ]
}

resource "azurerm_network_interface_backend_address_pool_association" "main2" {
  network_interface_id    = azurerm_network_interface.main[1].id
  ip_configuration_name   = "ip-conf-nic-1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.main.id
  depends_on = [
    azurerm_network_interface.main
  ]
}