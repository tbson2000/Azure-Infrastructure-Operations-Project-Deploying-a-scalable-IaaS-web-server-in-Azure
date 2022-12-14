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