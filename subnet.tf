resource "azurerm_subnet" "Deep-subnet" {
  name                 = "dev-subnet"
  resource_group_name  = azurerm_resource_group.Deep-rg.name
  virtual_network_name = azurerm_virtual_network.Deep-vnet.name
  address_prefixes     = ["10.123.1.0/24"]
}
