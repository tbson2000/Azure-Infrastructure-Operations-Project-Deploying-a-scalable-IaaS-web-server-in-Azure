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