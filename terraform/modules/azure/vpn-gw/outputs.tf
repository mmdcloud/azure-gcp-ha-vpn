output "gateway_id" {
  description = "ID of the Virtual Network Gateway"
  value       = azurerm_virtual_network_gateway.vng.id
}

output "gateway_name" {
  description = "Name of the Virtual Network Gateway"
  value       = azurerm_virtual_network_gateway.vng.name
}

output "public_ip_addresses" {
  description = "List of public IP addresses"
  value       = azurerm_public_ip.public_ip[*].ip_address
}

output "public_ip_ids" {
  description = "List of public IP resource IDs"
  value       = azurerm_public_ip.public_ip[*].id
}

output "bgp_settings" {
  description = "BGP settings of the gateway"
  value       = var.enable_bgp ? azurerm_virtual_network_gateway.vng.bgp_settings : null
}