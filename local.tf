
locals {
  resource_group_name="dev-rg"
  location="central india"
  virtual_network={
    name="dev-vnet"
    address_space="10.0.0.0/16"
  }

  subnets=[
    {
      name="private-subnet"
      address_prefix="10.0.0.0/24"
    },
    {
      name="public-subnet"
      address_prefix="10.0.1.0/24"
    }
  ]
}