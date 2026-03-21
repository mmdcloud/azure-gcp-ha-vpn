output "connection_ids" {
  description = "List of VPN connection IDs"
  value       = azurerm_virtual_network_gateway_connection.connection[*].id
}

output "connection_names" {
  description = "List of VPN connection names"
  value       = azurerm_virtual_network_gateway_connection.connection[*].name
}

output "shared_key" {
  description = "Shared key used for connections"
  value       = var.shared_key
  sensitive   = true
}