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



resource "tls_private_key" "linuxkey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "linuxpemkey"{
  filename = "linuxkey.pem"
  content=tls_private_key.linuxkey.private_key_pem
  depends_on = [
    tls_private_key.linuxkey
  ]
}

# creating jumpserver vm with standard size d2s 
resource "azurerm_linux_virtual_machine" "jumpserver" {
  name                = "jumpserver"
  resource_group_name = local.resource_group_name
  location            = local.location
  size                = "Standard_D2s_v3"
  admin_username      = "linuxusr"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.jumpserver.id
  ]
  admin_ssh_key {
     username="linuxusr"
     public_key = tls_private_key.linuxkey.public_key_openssh
   }

   
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
    azurerm_resource_group.appgrp,
    tls_private_key.linuxkey
    
  ]
}