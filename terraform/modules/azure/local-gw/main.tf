locals {
  gateways = {
    for idx in range(length(var.gateway_addresses)) :
    tostring(idx) => {
      address             = var.gateway_addresses[idx]
      bgp_peering_address = var.enable_bgp ? var.bgp_peering_addresses[idx] : null
    }
  }
}

resource "azurerm_local_network_gateway" "local_gw" {
  for_each            = local.gateways
  name                = "${var.gateway_name_prefix}-${each.key + 1}"
  location            = var.location
  resource_group_name = var.resource_group_name

  gateway_address = each.value.address

  dynamic "bgp_settings" {
    for_each = var.enable_bgp ? [1] : []
    content {
      asn                 = var.bgp_asn
      bgp_peering_address = each.value.bgp_peering_address
    }
  }

  tags = var.tags
}