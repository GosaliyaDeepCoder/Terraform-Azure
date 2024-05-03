resource "azurerm_network_security_group" "Deep-NSG" {
  name                = "dev-nsg"
  location            = azurerm_resource_group.Deep-rg.location
  resource_group_name = azurerm_resource_group.Deep-rg.name

  tags = {
    environment = "dev"
  }
}

resource "azurerm_network_security_rule" "Deep-dev-rule" {
  name                        = "dev-secrule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.Deep-rg.name
  network_security_group_name = azurerm_network_security_group.Deep-NSG.name
}

resource "azurerm_subnet_network_security_group_association" "Deep-sg-a" {
  subnet_id                 = azurerm_subnet.Deep-subnet.id
  network_security_group_id = azurerm_network_security_group.Deep-NSG.id
}
