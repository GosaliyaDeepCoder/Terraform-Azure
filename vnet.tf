resource "azurerm_virtual_network" "Deep-vnet" {
  name                = "dev-network"
  resource_group_name = azurerm_resource_group.Deep-rg.name
  location            = azurerm_resource_group.Deep-rg.location
  address_space       = ["10.123.0.0/16"]

  tags = {
    environment = "dev"
  }
}