output "router_id" {
  description = "ID of the Cloud Router"
  value       = google_compute_router.router.id
}

output "router_name" {
  description = "Name of the Cloud Router"
  value       = google_compute_router.router.name
}

output "interface_names" {
  description = "List of router interface names"
  value       = google_compute_router_interface.interfaces[*].name
}

output "peer_names" {
  description = "List of BGP peer names"
  value       = google_compute_router_peer.peers[*].name
}