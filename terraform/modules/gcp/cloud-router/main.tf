# GCP Cloud Router Module
# Creates Cloud Router with BGP configuration, interfaces, and peers

resource "google_compute_router" "router" {
  name    = var.router_name
  network = var.vpc_id
  region  = var.region

  bgp {
    advertise_mode    = var.bgp_advertise_mode
    advertised_groups = var.bgp_advertised_groups
    asn               = var.bgp_asn

    dynamic "advertised_ip_ranges" {
      for_each = var.bgp_advertised_ip_ranges
      content {
        range       = advertised_ip_ranges.value.range
        description = advertised_ip_ranges.value.description
      }
    }
  }

  project = var.project_id
}

resource "google_compute_router_interface" "interfaces" {
  count      = length(var.router_interfaces)
  name       = var.router_interfaces[count.index].name
  router     = google_compute_router.router.name
  region     = var.region
  ip_range   = var.router_interfaces[count.index].ip_range
  vpn_tunnel = var.router_interfaces[count.index].vpn_tunnel_name

  project = var.project_id
}

resource "google_compute_router_peer" "peers" {
  count           = length(var.bgp_peers)
  name            = var.bgp_peers[count.index].name
  router          = google_compute_router.router.name
  region          = var.region
  peer_ip_address = var.bgp_peers[count.index].peer_ip_address
  peer_asn        = var.bgp_peers[count.index].peer_asn
  interface       = google_compute_router_interface.interfaces[count.index].name

  advertised_route_priority = var.bgp_peers[count.index].advertised_route_priority

  project = var.project_id
}