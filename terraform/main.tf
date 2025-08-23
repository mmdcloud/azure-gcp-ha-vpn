# ---------------------------
# Azure Configuration
# ---------------------------
resource "azurerm_resource_group" "rg" {
  name     = "azure-vpn"
  location = "centralindia"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "gateway_subnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.1.1.0/24"]
}

resource "azurerm_public_ip" "public_ip_1" {
  name                = "public-ip-1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

resource "azurerm_public_ip" "public_ip_2" {
  name                = "public-ip-2"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "vng" {
  name                = "azure-vpn-gateway"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  type          = "Vpn"
  vpn_type      = "RouteBased"
  sku           = "VpnGw2AZ"
  generation    = "Generation2"
  active_active = true
  enable_bgp    = true

  ip_configuration {
    name                          = "public-ip-1"
    public_ip_address_id          = azurerm_public_ip.public_ip_1.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gateway_subnet.id
  }

  ip_configuration {
    name                          = "public-ip-2"
    public_ip_address_id          = azurerm_public_ip.public_ip_1.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gateway_subnet.id
  }

  bgp_settings {
    asn = 65515
    dynamic "peering_addresses" {
      for_each = var.bgp_addresses
      content {
        ip_configuration_name = peering_addresses.value.ip_configuration_name
        apipa_addresses       = peering_addresses.value.apipa_addresses
      }
    }
  }
}

# Local Network Gateway
resource "azurerm_local_network_gateway" "local_gw_1" {
  name                = "local-gw-1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  gateway_address = google_compute_ha_vpn_gateway.gcp_vpn_gateway.interfaces[0].ip_address

  bgp_settings {
    asn                 = 65001
    bgp_peering_address = "169.254.21.9"
  }

  tags = {
    environment = "production"
  }
}

resource "azurerm_local_network_gateway" "local_gw_2" {
  name                = "local-gw-2"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  gateway_address = google_compute_ha_vpn_gateway.gcp_vpn_gateway.interfaces[1].ip_address

  bgp_settings {
    asn                 = 65001
    bgp_peering_address = "169.254.21.13"
  }

  tags = {
    environment = "production"
  }
}

resource "azurerm_virtual_network_gateway_connection" "connection1" {
  name                       = "connection1"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vng.id
  local_network_gateway_id   = azurerm_local_network_gateway.local_gw_1.id
  shared_key                 = "Mohitdixit12345!"
  enable_bgp                 = true
}

resource "azurerm_virtual_network_gateway_connection" "connection2" {
  name                       = "connection2"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vng.id
  local_network_gateway_id   = azurerm_local_network_gateway.local_gw_2.id
  shared_key                 = "Mohitdixit12345!"
  enable_bgp                 = true
}

# ---------------------------
# GCP Configuration
# ---------------------------
# Create a HA VPN gateway in GCP
resource "google_compute_ha_vpn_gateway" "gcp_vpn_gateway" {
  name               = "gcp-vpn-gateway"
  network            = module.source_vpc.vpc_id
  gateway_ip_version = "IPV4"
  region             = "asia-south1"
}

# Create a cloud router for BGP (optional)
resource "google_compute_router" "gcp_router" {
  name    = "gcp-vpn-router"
  network = module.source_vpc.vpc_id
  region  = "asia-south1"

  bgp {
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]
    asn               = 65001
  }
}

# Create external VPN gateway representing the AWS side
resource "google_compute_external_vpn_gateway" "azure_vpn_gateway" {
  name            = "azure-vpn-gateway"
  redundancy_type = "TWO_IPS_REDUNDANCY"
  description     = "Azure VPN Gateway"
  interface {
    id         = 0
    ip_address = azurerm_public_ip.public_ip_1.ip_address
  }
  interface {
    id         = 1
    ip_address = azurerm_public_ip.public_ip_2.ip_address
  }
}

# Create VPN tunnels on GCP side
resource "google_compute_vpn_tunnel" "gcp_tunnel1" {
  name                            = "gcp-tunnel1"
  region                          = "asia-south1"
  vpn_gateway                     = google_compute_ha_vpn_gateway.gcp_vpn_gateway.id
  peer_external_gateway           = google_compute_external_vpn_gateway.azure_vpn_gateway.id
  vpn_gateway_interface           = 0
  peer_external_gateway_interface = 0
  ike_version                     = 2
  shared_secret                   = azurerm_virtual_network_gateway_connection.connection1.shared_key
  router                          = google_compute_router.gcp_router.id
}

resource "google_compute_vpn_tunnel" "gcp_tunnel2" {
  name                            = "gcp-tunnel2"
  region                          = "asia-south1"
  vpn_gateway                     = google_compute_ha_vpn_gateway.gcp_vpn_gateway.id
  peer_external_gateway           = google_compute_external_vpn_gateway.azure_vpn_gateway.id
  vpn_gateway_interface           = 1
  peer_external_gateway_interface = 1
  ike_version                     = 2
  shared_secret                   = azurerm_virtual_network_gateway_connection.connection2.shared_key
  router                          = google_compute_router.gcp_router.id
}

# Create BGP sessions (optional)
resource "google_compute_router_peer" "gcp_bgp_peer1" {
  name            = "gcp-bgp-peer1"
  router          = google_compute_router.gcp_router.name
  region          = "asia-south1"
  peer_ip_address = "169.254.21.10"
  peer_asn        = 65515
  # advertised_route_priority = 100
  interface = google_compute_router_interface.gcp_interface1.name
}

resource "google_compute_router_peer" "gcp_bgp_peer2" {
  name            = "gcp-bgp-peer2"
  router          = google_compute_router.gcp_router.name
  region          = "asia-south1"
  peer_ip_address = "169.254.21.14"
  peer_asn        = 65515
  # advertised_route_priority = 100
  interface = google_compute_router_interface.gcp_interface2.name
}

resource "google_compute_router_interface" "gcp_interface1" {
  name       = "gcp-interface1"
  router     = google_compute_router.gcp_router.name
  region     = "asia-south1"
  ip_range   = "169.254.21.9/30"
  vpn_tunnel = google_compute_vpn_tunnel.gcp_tunnel1.name
}

resource "google_compute_router_interface" "gcp_interface2" {
  name       = "gcp-interface2"
  router     = google_compute_router.gcp_router.name
  region     = "asia-south1"
  ip_range   = "169.254.21.13/30"
  vpn_tunnel = google_compute_vpn_tunnel.gcp_tunnel2.name
}

# ---------------------------
# Test Instances
# ---------------------------
