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