output "vm_id" {
  description = "ID of the virtual machine"
  value       = azurerm_linux_virtual_machine.vm.id
}

output "vm_name" {
  description = "Name of the virtual machine"
  value       = azurerm_linux_virtual_machine.vm.name
}

output "private_ip_address" {
  description = "Private IP address of the VM"
  value       = azurerm_network_interface.vm_nic.private_ip_address
}

output "public_ip_address" {
  description = "Public IP address of the VM"
  value       = var.create_public_ip ? azurerm_public_ip.vm_public_ip[0].ip_address : null
}

output "network_interface_id" {
  description = "ID of the network interface"
  value       = azurerm_network_interface.vm_nic.id
}

output "nsg_id" {
  description = "ID of the Network Security Group"
  value       = var.create_nsg ? azurerm_network_security_group.nsg[0].id : null
}