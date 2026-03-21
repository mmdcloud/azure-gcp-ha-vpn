resource "azurerm_virtual_network_gateway_connection" "connection" {
  count                      = length(var.local_network_gateway_ids)
  name                       = "${var.connection_name_prefix}-${count.index + 1}"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  type                       = var.connection_type
  virtual_network_gateway_id = var.virtual_network_gateway_id
  local_network_gateway_id   = var.local_network_gateway_ids[count.index]
  shared_key                 = var.shared_key
  enable_bgp                 = var.enable_bgp

  dynamic "ipsec_policy" {
    for_each = var.custom_ipsec_policy != null ? [var.custom_ipsec_policy] : []
    content {
      dh_group         = ipsec_policy.value.dh_group
      ike_encryption   = ipsec_policy.value.ike_encryption
      ike_integrity    = ipsec_policy.value.ike_integrity
      ipsec_encryption = ipsec_policy.value.ipsec_encryption
      ipsec_integrity  = ipsec_policy.value.ipsec_integrity
      pfs_group        = ipsec_policy.value.pfs_group
      sa_datasize      = ipsec_policy.value.sa_datasize
      sa_lifetime      = ipsec_policy.value.sa_lifetime
    }
  }

  tags = var.tags
}