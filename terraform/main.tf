provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "urg" {
  name     = "UdacityDevOpsRG"
  location = "East US"

  tags = var.required_tag
}

resource "azurerm_virtual_network" "uvnet" {
  name                = "UdacityDevOpsVnet"
  resource_group_name = azurerm_resource_group.urg.name
  location            = azurerm_resource_group.urg.location
  address_space       = ["10.0.0.0/16"]

  tags = var.required_tag
}

resource "azurerm_subnet" "usubnet1" {
  name                 = "UdacitySubnet01"
  resource_group_name  = azurerm_resource_group.urg.name
  virtual_network_name = azurerm_virtual_network.uvnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "unsg" {
  name                = "UdacityNSG"
  location            = azurerm_resource_group.urg.location
  resource_group_name = azurerm_resource_group.urg.name

  tags = var.required_tag
}

resource "azurerm_network_security_rule" "unsr_allowvm_inbound" {
  name                        = "allowVmInSameSubnet_Inbound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "10.0.1.0/24"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.urg.name
  network_security_group_name = azurerm_network_security_group.unsg.name
}
resource "azurerm_network_security_rule" "unsr_allowvm_outbound" {
  name                        = "allowVmInSameSubnet_Outbound"
  priority                    = 110
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "10.0.1.0/24"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.urg.name
  network_security_group_name = azurerm_network_security_group.unsg.name
}

resource "azurerm_network_security_rule" "unsr_denyinternetaccess" {
  name                        = "denyInternetAccess"
  priority                    = 4096
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.urg.name
  network_security_group_name = azurerm_network_security_group.unsg.name
}

resource "azurerm_network_security_rule" "unsr_httpallowlb-vm" {
  name                        = "Allow HTTP from LB to VM"
  priority                    = 120
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "AzureLoadBalancer"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.urg.name
  network_security_group_name = azurerm_network_security_group.unsg.name
}

# Azure network

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

# virtual machine

resource "azurerm_availability_set" "uas" {
  name                = "udacity-as"
  location            = azurerm_resource_group.urg.location
  resource_group_name = azurerm_resource_group.urg.name

  tags = var.required_tag
}

resource "azurerm_linux_virtual_machine" "ulvm" {
  name                            = format("udacity-machine-%d", count.index)
  resource_group_name             = azurerm_resource_group.urg.name
  location                        = azurerm_resource_group.urg.location
  size                            = "Standard_DS2_V2"
  admin_username                  = "admin"
  admin_password                  = "Pa55w.rd"
  availability_set_id             = azurerm_availability_set.uas.id
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.unic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_id = var.image_id

  tags = var.required_tag

  count = var.vm_num
}