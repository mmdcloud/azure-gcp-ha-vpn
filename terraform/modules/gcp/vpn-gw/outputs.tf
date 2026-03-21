output "gateway_id" {
  description = "ID of the HA VPN Gateway"
  value       = google_compute_ha_vpn_gateway.ha_vpn_gateway.id
}

output "gateway_name" {
  description = "Name of the HA VPN Gateway"
  value       = google_compute_ha_vpn_gateway.ha_vpn_gateway.name
}

output "vpn_interfaces" {
  description = "VPN interfaces with IP addresses"
  value       = google_compute_ha_vpn_gateway.ha_vpn_gateway.vpn_interfaces
}

output "tunnel_ids" {
  description = "List of VPN tunnel IDs"
  value       = google_compute_vpn_tunnel.tunnels[*].id
}

output "tunnel_names" {
  description = "List of VPN tunnel names"
  value       = google_compute_vpn_tunnel.tunnels[*].name
}