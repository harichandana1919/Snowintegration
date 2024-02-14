# creating network interface for jumpserver [no public ip]
resource "azurerm_network_interface" "jumpserver" {
  name                = "jumpserver-nic"
  location            = local.location
  resource_group_name = local.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnetB.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.appip.id
  }
  depends_on = [
    azurerm_subnet.subnetB
  ]
}

# associating nic card to vm
resource "azurerm_subnet_network_security_group_association" "jumpassociate" {
  subnet_id                 = azurerm_subnet.subnetB.id
  network_security_group_id = azurerm_network_security_group.appnsg.id
}

# creating jumpserver vm with standard size d2s 
resource "azurerm_linux_virtual_machine" "jumpserver" {
  name                = "jumpserver"
  resource_group_name = local.resource_group_name
  location            = local.location
  size                = "Standard_D2s_v3"
  admin_username      = "linuxusr"
  admin_password      = "Randstad@123"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.jumpserver.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
  depends_on = [
    azurerm_network_interface.jumpserver,
    azurerm_resource_group.appgrp   
  ]
}