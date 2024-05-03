resource "azurerm_public_ip" "Deep-ip" {
  name                = "dev-vm-ip"
  resource_group_name = azurerm_resource_group.Deep-rg.name
  location            = azurerm_resource_group.Deep-rg.location
  allocation_method   = "Dynamic"

  tags = {
    environment = "dev"
  }
}