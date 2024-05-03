resource "azurerm_resource_group" "Deep-rg" {
  name     = "az-tf-rg"
  location = "East US"
  tags = {
    environment = "dev"
  }
}









