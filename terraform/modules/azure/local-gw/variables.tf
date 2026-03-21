variable "gateway_name_prefix" {
  description = "Prefix for local network gateway names"
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

variable "gateway_addresses" {
  description = "List of remote gateway IP addresses (GCP VPN interfaces)"
  type        = list(string)
}

variable "enable_bgp" {
  description = "Enable BGP routing"
  type        = bool
  default     = true
}

variable "bgp_asn" {
  description = "Remote BGP ASN number"
  type        = number
  default     = 65001
}

variable "bgp_peering_addresses" {
  description = "List of BGP peering addresses for each gateway"
  type        = list(string)
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}