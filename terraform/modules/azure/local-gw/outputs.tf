output "local_gateway_ids" {
  description = "List of Local Network Gateway IDs"
  value       = azurerm_local_network_gateway.local_gw[*].id
}

output "local_gateway_names" {
  description = "List of Local Network Gateway names"
  value       = azurerm_local_network_gateway.local_gw[*].name
}