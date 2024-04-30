terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.101.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "Deep-rg" {
  name     = "az-tf-rg"
  location = "East US"
  tags = {
    environment = "dev"
  }
}

resource "azurerm_virtual_network" "Deep-vnet" {
  name                = "dev-network"
  resource_group_name = azurerm_resource_group.Deep-rg.name
  location            = azurerm_resource_group.Deep-rg.location
  address_space       = ["10.123.0.0/16"]

  tags = {
    environment = "dev"
  }
}

resource "azurerm_subnet" "Deep-subnet" {
  name                 = "dev-subnet"
  resource_group_name  = azurerm_resource_group.Deep-rg.name
  virtual_network_name = azurerm_virtual_network.Deep-vnet.name
  address_prefixes     = ["10.123.1.0/24"]
}

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

resource "azurerm_public_ip" "Deep-ip" {
  name                = "dev-vm-ip"
  resource_group_name = azurerm_resource_group.Deep-rg.name
  location            = azurerm_resource_group.Deep-rg.location
  allocation_method   = "Dynamic"

  tags = {
    environment = "dev"
  }
}

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

resource "azurerm_linux_virtual_machine" "Deep-vm" {
  name                  = "dev-machine"
  resource_group_name   = azurerm_resource_group.Deep-rg.name
  location              = azurerm_resource_group.Deep-rg.location
  size                  = "Standard_B1s"
  admin_username        = "adminuser"
  network_interface_ids = [azurerm_network_interface.Deep-NIC.id, ]

  custom_data = filebase64("customdata.tpl")

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/tfazkey.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  provisioner "local-exec" {
    command = templatefile("${var.host_os}-ssh-script.tpl", {
      hostname     = self.public_ip_address,
      user         = "adminuser",
      identityfile = "~/.ssh/tfazkey"
    })
    interpreter = var.host_os == "windows" ? ["PowerShell", "-Command"] : ["bash", "-c"]

  }

  tags = {
    environment = "dev"
  }
}

data "azurerm_public_ip" "Deep-ip-data" {
  name                = azurerm_public_ip.Deep-ip.name
  resource_group_name = azurerm_resource_group.Deep-rg.name
}

output "public_ip_address" {
  value = "${azurerm_linux_virtual_machine.Deep-vm.name}: ${data.azurerm_public_ip.Deep-ip-data.ip_address}"
}