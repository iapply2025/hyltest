resource "azurerm_network_interface" "control_nic" {
  name                = "${var.prefix}-control-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipcfg"
    subnet_id                     = azurerm_subnet.control.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "control" {
  name                = "${var.prefix}-control"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  size                = var.control_vm_size
  admin_username      = var.admin_username
  network_interface_ids = [azurerm_network_interface.control_nic.id]
  disable_password_authentication = true

  identity { type = "SystemAssigned" }

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    caching = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
    disk_size_gb = 40
  }

  source_image_reference {
    publisher = "resf"
    offer     = "rockylinux-x86_64"
    sku       = "9-base"
    version   = "latest"
  }
  plan {
    name = "9-base"
    product = "rockylinux-x86_64"
    publisher = "resf"
  }

  custom_data = filebase64("${path.module}/cloud-init-control.yml")

  tags = { role = "ansible-control", project = var.prefix }
}
