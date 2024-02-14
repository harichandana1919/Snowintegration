# creating nsg rules
resource "azurerm_network_security_group" "appnsg" {
  name                = "dev-nsg"
  location            = local.location
  resource_group_name = local.resource_group_name

  security_rule {
    name                       = "Allowhttp"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "http"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }


    

  depends_on = [
    azurerm_resource_group.appgrp
  ]
}
