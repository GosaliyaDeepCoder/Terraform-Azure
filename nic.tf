resource "azurerm_network_interface" "Deep-NIC" {
  name                = "dev-nic"
  location            = azurerm_resource_group.Deep-rg.location
  resource_group_name = azurerm_resource_group.Deep-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.Deep-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.Deep-ip.id
  }

  tags = {
    environment = "dev"
  }
}