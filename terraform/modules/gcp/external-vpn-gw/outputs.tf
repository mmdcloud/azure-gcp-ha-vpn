output "gateway_id" {
  description = "ID of the external VPN gateway"
  value       = google_compute_external_vpn_gateway.external_gateway.id
}

output "gateway_name" {
  description = "Name of the external VPN gateway"
  value       = google_compute_external_vpn_gateway.external_gateway.name
}

output "interfaces" {
  description = "External gateway interfaces"
  value       = google_compute_external_vpn_gateway.external_gateway.interface
}