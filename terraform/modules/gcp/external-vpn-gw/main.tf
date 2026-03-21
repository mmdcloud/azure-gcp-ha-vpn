# GCP External VPN Gateway Module
# Represents the Azure VPN Gateway as an external gateway in GCP

resource "google_compute_external_vpn_gateway" "external_gateway" {
  name            = var.gateway_name
  redundancy_type = var.redundancy_type
  description     = var.description

  dynamic "interface" {
    for_each = var.interfaces
    content {
      id         = interface.value.id
      ip_address = interface.value.ip_address
    }
  }

  project = var.project_id
}