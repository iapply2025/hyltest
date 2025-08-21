output "public_ip" {
  value = azurerm_public_ip.pip.ip_address
}

output "admin_user" {
  value = var.admin_username
}

output "vm_id" {
  value = azurerm_linux_virtual_machine.vm.id
}

output "resource_group" {
  value = azurerm_resource_group.rg.name
}

output "control_vm_name" {
  value = azurerm_linux_virtual_machine.control.name
}

output "app_private_ip" {
  value = azurerm_network_interface.nic.ip_configuration[0].private_ip_address
}