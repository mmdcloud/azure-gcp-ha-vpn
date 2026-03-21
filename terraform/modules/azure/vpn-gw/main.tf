# Azure VPN Gateway Module
# Creates public IPs and Virtual Network Gateway for HA VPN

resource "azurerm_public_ip" "public_ip" {
  count               = var.active_active ? 2 : 1
  name                = "${var.gateway_name}-public-ip-${count.index + 1}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  zones               = var.zones
  sku                 = "Standard"

  tags = var.tags
}

resource "azurerm_virtual_network_gateway" "vng" {
  name                = var.gateway_name
  location            = var.location
  resource_group_name = var.resource_group_name

  type          = var.gateway_type
  vpn_type      = var.vpn_type
  sku           = var.gateway_sku
  generation    = var.generation
  active_active = var.active_active
  enable_bgp    = var.enable_bgp

  dynamic "ip_configuration" {
    for_each = var.active_active ? [1, 2] : [1]
    content {
      name                          = "ip-config-${ip_configuration.value}"
      public_ip_address_id          = azurerm_public_ip.public_ip[ip_configuration.value - 1].id
      private_ip_address_allocation = "Dynamic"
      subnet_id                     = var.gateway_subnet_id
    }
  }

  dynamic "bgp_settings" {
    for_each = var.enable_bgp ? [1] : []
    content {
      asn = var.bgp_asn

      dynamic "peering_addresses" {
        for_each = var.bgp_peering_addresses
        content {
          ip_configuration_name = peering_addresses.value.ip_configuration_name
          apipa_addresses       = peering_addresses.value.apipa_addresses
        }
      }
    }
  }

  tags = var.tags
}