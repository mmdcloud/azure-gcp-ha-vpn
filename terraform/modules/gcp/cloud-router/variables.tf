variable "router_name" {
  description = "Name of the Cloud Router"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC network"
  type        = string
}

variable "region" {
  description = "GCP region for the router"
  type        = string
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
  default     = null
}

variable "bgp_asn" {
  description = "BGP ASN for the router"
  type        = number
  default     = 65001
}

variable "bgp_advertise_mode" {
  description = "BGP advertise mode (DEFAULT or CUSTOM)"
  type        = string
  default     = "CUSTOM"
}

variable "bgp_advertised_groups" {
  description = "List of BGP advertised groups"
  type        = list(string)
  default     = ["ALL_SUBNETS"]
}

variable "bgp_advertised_ip_ranges" {
  description = "Custom IP ranges to advertise via BGP"
  type = list(object({
    range       = string
    description = string
  }))
  default = []
}

variable "router_interfaces" {
  description = "List of router interface configurations"
  type = list(object({
    name            = string
    ip_range        = string
    vpn_tunnel_name = string
  }))
}

variable "bgp_peers" {
  description = "List of BGP peer configurations"
  type = list(object({
    name                      = string
    peer_ip_address           = string
    peer_asn                  = number
    advertised_route_priority = optional(number)
  }))
}