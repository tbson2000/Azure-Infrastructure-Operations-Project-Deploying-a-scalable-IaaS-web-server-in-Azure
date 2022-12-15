resource "azurerm_network_interface" "unic" {
  name                = "UdacityNIC"
  location            = azurerm_resource_group.urg.location
  resource_group_name = azurerm_resource_group.urg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.usubnet1.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.required_tag
}

resource "azurerm_public_ip" "upip" {
  name                = "UdacityPubIP"
  resource_group_name = azurerm_resource_group.urg.name
  location            = azurerm_resource_group.urg.location
  allocation_method   = "Dynamic"

  tags = var.required_tag
}

resource "azurerm_lb" "ulb" {
  name                = "UdacityLB"
  location            = azurerm_resource_group.urg.location
  resource_group_name = azurerm_resource_group.urg.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.upip.id
  }

  tags = var.required_tag
}

resource "azurerm_lb_backend_address_pool" "ulb_bap" {
  loadbalancer_id = azurerm_lb.ulb.id
  name            = "UdacityLBBackendAddressPool"
}

resource "azurerm_network_interface_backend_address_pool_association" "unibapa" {
  network_interface_id    = azurerm_network_interface.unic.id
  ip_configuration_name   = "PublicIPAddress"
  backend_address_pool_id = azurerm_lb_backend_address_pool.ulb_bap.id
}