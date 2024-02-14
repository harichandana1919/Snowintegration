# creating resource group from local variable 
resource "azurerm_resource_group" "appgrp" {
  name     = local.resource_group_name
  location = local.location  
}



# creating network interface for linux vm
resource "azurerm_network_interface" "appinterface" {
  name                = "appinterface"
  location            = local.location
  resource_group_name = local.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnetA.id
    private_ip_address_allocation = "Dynamic"
  }
  depends_on = [
    azurerm_subnet.subnetA
  ]
}

# associating nic card to vm
resource "azurerm_subnet_network_security_group_association" "appnsglink" {
  subnet_id                 = azurerm_subnet.subnetA.id
  network_security_group_id = azurerm_network_security_group.appnsg.id
}


resource "tls_private_key" "linuxkey1" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "linuxpemkey1"{
  filename = "linuxkey1.pem"
  content=tls_private_key.linuxkey1.private_key_pem
  depends_on = [
    tls_private_key.linuxkey1
  ]
}



# creating linux vm with standard size d2s 
resource "azurerm_linux_virtual_machine" "linuxvm" {
  name                = "linuxvm"
  resource_group_name = local.resource_group_name
  location            = local.location
  size                = "Standard_D2s_v3"
  admin_username      = "linuxusr"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.appinterface.id
  ]
  admin_ssh_key {
     username="linuxusr"
     public_key = tls_private_key.linuxkey1.public_key_openssh
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
    azurerm_network_interface.appinterface,
    azurerm_resource_group.appgrp,
    tls_private_key.linuxkey
    
  ]
}


# Custom script to install Apache
resource "azurerm_virtual_machine_extension" "example" {
  name                 = "Apache"
  virtual_machine_id   = azurerm_linux_virtual_machine.linuxvm.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
        "commandToExecute": "sudo apt update && sudo apt install -y apache2"
    }
SETTINGS
}
