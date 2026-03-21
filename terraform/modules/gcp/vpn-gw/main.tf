# GCP HA VPN Gateway Module
# Creates HA VPN Gateway with tunnels

resource "google_compute_ha_vpn_gateway" "ha_vpn_gateway" {
  name               = var.gateway_name
  network            = var.vpc_id
  region             = var.region
  gateway_ip_version = var.gateway_ip_version

  project = var.project_id
}

resource "google_compute_vpn_tunnel" "tunnels" {
  count                           = length(var.tunnel_configs)
  name                            = "${var.gateway_name}-tunnel-${count.index + 1}"
  region                          = var.region
  vpn_gateway                     = google_compute_ha_vpn_gateway.ha_vpn_gateway.id
  peer_external_gateway           = var.peer_external_gateway_id
  vpn_gateway_interface           = var.tunnel_configs[count.index].vpn_gateway_interface
  peer_external_gateway_interface = var.tunnel_configs[count.index].peer_external_gateway_interface
  ike_version                     = var.ike_version
  shared_secret                   = var.shared_secret
  router                          = var.router_id

  project = var.project_id

  depends_on = [google_compute_ha_vpn_gateway.ha_vpn_gateway]
}