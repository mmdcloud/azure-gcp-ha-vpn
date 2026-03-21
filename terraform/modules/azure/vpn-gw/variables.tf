variable "gateway_name" {
  description = "Name of the Virtual Network Gateway"
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

variable "gateway_subnet_id" {
  description = "ID of the GatewaySubnet"
  type        = string
}

variable "gateway_type" {
  description = "Type of gateway (Vpn or ExpressRoute)"
  type        = string
  default     = "Vpn"
}

variable "vpn_type" {
  description = "VPN type (RouteBased or PolicyBased)"
  type        = string
  default     = "RouteBased"
}

variable "gateway_sku" {
  description = "SKU of the Virtual Network Gateway"
  type        = string
  default     = "VpnGw2AZ"
}

variable "generation" {
  description = "Gateway generation (Generation1 or Generation2)"
  type        = string
  default     = "Generation2"
}

variable "active_active" {
  description = "Enable active-active configuration"
  type        = bool
  default     = true
}

variable "enable_bgp" {
  description = "Enable BGP routing"
  type        = bool
  default     = true
}

variable "bgp_asn" {
  description = "BGP ASN number"
  type        = number
  default     = 65515
}

variable "bgp_peering_addresses" {
  description = "BGP peering addresses configuration"
  type = list(object({
    ip_configuration_name = string
    apipa_addresses       = list(string)
  }))
  default = []
}

variable "zones" {
  description = "Availability zones for public IPs"
  type        = list(string)
  default     = ["1"]
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}