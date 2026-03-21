variable "connection_name_prefix" {
  description = "Prefix for VPN connection names"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "connection_type" {
  description = "Type of connection (IPsec, ExpressRoute, Vnet2Vnet)"
  type        = string
  default     = "IPsec"
}

variable "virtual_network_gateway_id" {
  description = "ID of the Virtual Network Gateway"
  type        = string
}

variable "local_network_gateway_ids" {
  description = "List of Local Network Gateway IDs"
  type        = list(string)
}

variable "shared_key" {
  description = "Shared key for VPN connection"
  type        = string
  sensitive   = true
}

variable "enable_bgp" {
  description = "Enable BGP for the connection"
  type        = bool
  default     = true
}

variable "custom_ipsec_policy" {
  description = "Custom IPsec policy configuration"
  type = object({
    dh_group         = string
    ike_encryption   = string
    ike_integrity    = string
    ipsec_encryption = string
    ipsec_integrity  = string
    pfs_group        = string
    sa_datasize      = optional(number)
    sa_lifetime      = optional(number)
  })
  default = null
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}