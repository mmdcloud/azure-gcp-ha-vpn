variable "gateway_name" {
  description = "Name of the HA VPN Gateway"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC network"
  type        = string
}

variable "region" {
  description = "GCP region for the VPN gateway"
  type        = string
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
  default     = null
}

variable "gateway_ip_version" {
  description = "IP version for the gateway (IPV4 or IPV6)"
  type        = string
  default     = "IPV4"
}

variable "tunnel_configs" {
  description = "List of tunnel configurations"
  type = list(object({
    vpn_gateway_interface           = number
    peer_external_gateway_interface = number
  }))
}

variable "peer_external_gateway_id" {
  description = "ID of the external VPN gateway (Azure side)"
  type        = string
}

variable "router_id" {
  description = "ID of the Cloud Router"
  type        = string
}

variable "ike_version" {
  description = "IKE protocol version (1 or 2)"
  type        = number
  default     = 2
}

variable "shared_secret" {
  description = "Shared secret for VPN tunnels"
  type        = string
  sensitive   = true
}