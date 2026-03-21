variable "bgp_addresses" {
  type = list(object({
    ip_configuration_name = string
    apipa_addresses       = list(string)
  }))
  default = [{
    ip_configuration_name = "ip-config-1"
    apipa_addresses       = ["169.254.21.10"]
    }, {
    ip_configuration_name = "ip-config-2"
    apipa_addresses       = ["169.254.21.14"]
  }]
}

variable "gcp_location" {
  type    = string
  default = "asia-south1"
}

variable "gcp_public_subnets" {
  type    = list(string)
  default = ["10.2.1.0/24", "10.2.2.0/24", "10.2.3.0/24"]
}

variable "gcp_private_subnets" {
  type    = list(string)
  default = ["10.2.4.0/24", "10.2.5.0/24", "10.2.6.0/24"]
}

# variable "gcp_project_id" {
#   type        = string
#   description = "GCP Project ID"
#   default     = "encoded-alpha-457108-e8"
# }

# =============================================================================
# Azure-GCP HA VPN Variables
# =============================================================================

# -----------------------------------------------------------------------------
# Azure Variables
# -----------------------------------------------------------------------------
variable "azure_resource_group_name" {
  description = "Name of the Azure resource group"
  type        = string
  default     = "azure-vpn"
}

variable "azure_location" {
  description = "Azure region for resources"
  type        = string
  default     = "centralindia"
}

variable "azure_vnet_name" {
  description = "Name of the Azure virtual network"
  type        = string
  default     = "azure-vnet"
}

variable "azure_address_space" {
  description = "Address space for Azure VNet"
  type        = list(string)
  default     = ["10.1.0.0/16"]
}

variable "azure_subnets" {
  description = "List of subnets for Azure VNet"
  type = list(object({
    name             = string
    address_prefixes = list(string)
  }))
  default = [
    {
      name             = "default"
      address_prefixes = ["10.1.1.0/24"]
    },
    {
      name             = "GatewaySubnet"
      address_prefixes = ["10.1.2.0/24"]
    }
  ]
}

variable "azure_vpn_gateway_name" {
  description = "Name of the Azure VPN gateway"
  type        = string
  default     = "azure-vpn-gateway"
}

variable "azure_vpn_gateway_sku" {
  description = "SKU for Azure VPN gateway"
  type        = string
  default     = "VpnGw2AZ"
}

variable "azure_vpn_gateway_generation" {
  description = "Generation of Azure VPN gateway"
  type        = string
  default     = "Generation2"
}

variable "azure_vpn_active_active" {
  description = "Enable active-active configuration for Azure VPN"
  type        = bool
  default     = true
}

variable "azure_enable_bgp" {
  description = "Enable BGP for Azure VPN"
  type        = bool
  default     = true
}

variable "azure_bgp_asn" {
  description = "BGP ASN for Azure"
  type        = number
  default     = 65515
}

variable "azure_bgp_peering_addresses" {
  description = "BGP peering addresses for Azure VPN gateway"
  type = list(object({
    ip_configuration_name = string
    apipa_addresses       = list(string)
  }))
}

variable "azure_availability_zones" {
  description = "Availability zones for Azure public IPs"
  type        = list(string)
  default     = ["1"]
}

# Azure VM Variables
variable "azure_vm_name" {
  description = "Name of the Azure test VM"
  type        = string
  default     = "azure-vm"
}

variable "azure_vm_size" {
  description = "Size of the Azure VM"
  type        = string
  default     = "Standard_B1s"
}

variable "azure_vm_admin_username" {
  description = "Admin username for Azure VM"
  type        = string
  default     = "azureuser"
}

variable "azure_vm_admin_password" {
  description = "Admin password for Azure VM"
  type        = string
  sensitive   = true
}

variable "azure_vm_nsg_rules" {
  description = "NSG rules for Azure VM"
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
  default = [
    {
      name                       = "Allow-SSH"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "Allow-HTTP"
      priority                   = 200
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  ]
}

variable "azure_vm_image_publisher" {
  description = "Azure VM image publisher"
  type        = string
  default     = "Canonical"
}

variable "azure_vm_image_offer" {
  description = "Azure VM image offer"
  type        = string
  default     = "UbuntuServer"
}

variable "azure_vm_image_sku" {
  description = "Azure VM image SKU"
  type        = string
  default     = "18.04-LTS"
}

variable "azure_vm_image_version" {
  description = "Azure VM image version"
  type        = string
  default     = "latest"
}

# -----------------------------------------------------------------------------
# GCP Variables
# -----------------------------------------------------------------------------
variable "gcp_project_id" {
  description = "GCP project ID"
  type        = string
}

variable "gcp_region" {
  description = "GCP region for resources"
  type        = string
  default     = "asia-south1"
}

variable "gcp_vpc_name" {
  description = "Name of the GCP VPC"
  type        = string
  default     = "gcp-vpc"
}

variable "gcp_delete_default_routes" {
  description = "Delete default routes on GCP VPC creation"
  type        = bool
  default     = false
}

variable "gcp_auto_create_subnetworks" {
  description = "Auto-create subnetworks in GCP VPC"
  type        = bool
  default     = false
}

variable "gcp_routing_mode" {
  description = "Routing mode for GCP VPC"
  type        = string
  default     = "REGIONAL"
}

variable "gcp_subnets" {
  description = "List of subnets for GCP VPC"
  type = list(object({
    name                     = string
    region                   = string
    purpose                  = string
    role                     = string
    private_ip_google_access = bool
    ip_cidr_range            = string
  }))
}

variable "gcp_firewall_rules" {
  description = "Firewall rules for GCP VPC"
  type = list(object({
    name          = string
    source_ranges = list(string)
    allow_list = list(object({
      protocol = string
      ports    = list(string)
    }))
    target_tags = list(string)
  }))
  default = [
    {
      name          = "allow-ssh"
      source_ranges = ["0.0.0.0/0"]
      allow_list = [
        {
          protocol = "tcp"
          ports    = ["22"]
        }
      ]
      target_tags = ["gcp-instance"]
    }
  ]
}

variable "gcp_router_name" {
  description = "Name of the GCP Cloud Router"
  type        = string
  default     = "gcp-vpn-router"
}

variable "gcp_bgp_asn" {
  description = "BGP ASN for GCP"
  type        = number
  default     = 65001
}

variable "gcp_bgp_advertise_mode" {
  description = "BGP advertise mode for GCP router"
  type        = string
  default     = "CUSTOM"
}

variable "gcp_bgp_advertised_groups" {
  description = "BGP advertised groups for GCP"
  type        = list(string)
  default     = ["ALL_SUBNETS"]
}

variable "gcp_bgp_advertised_ip_ranges" {
  description = "Custom IP ranges to advertise via BGP on GCP"
  type = list(object({
    range       = string
    description = string
  }))
  default = []
}

variable "gcp_bgp_peering_addresses" {
  description = "BGP peering addresses for GCP (Azure side)"
  type        = list(string)
  default     = ["169.254.21.9", "169.254.21.13"]
}

variable "gcp_router_interfaces" {
  description = "Router interfaces configuration for GCP"
  type = list(object({
    name            = string
    ip_range        = string
    vpn_tunnel_name = string
  }))
}

variable "gcp_bgp_peers" {
  description = "BGP peers configuration for GCP"
  type = list(object({
    name                      = string
    peer_ip_address           = string
    peer_asn                  = number
    advertised_route_priority = optional(number)
  }))
}

variable "gcp_external_gateway_name" {
  description = "Name of the GCP external VPN gateway (Azure)"
  type        = string
  default     = "azure-vpn-gateway"
}

variable "gcp_external_gateway_redundancy_type" {
  description = "Redundancy type for GCP external gateway"
  type        = string
  default     = "TWO_IPS_REDUNDANCY"
}

variable "gcp_external_gateway_description" {
  description = "Description for GCP external gateway"
  type        = string
  default     = "Azure VPN Gateway"
}

variable "gcp_ha_vpn_gateway_name" {
  description = "Name of the GCP HA VPN gateway"
  type        = string
  default     = "gcp-vpn-gateway"
}

variable "gcp_gateway_ip_version" {
  description = "IP version for GCP HA VPN gateway"
  type        = string
  default     = "IPV4"
}

variable "gcp_ike_version" {
  description = "IKE version for GCP VPN tunnels"
  type        = number
  default     = 2
}

variable "gcp_tunnel_configs" {
  description = "Tunnel configurations for GCP HA VPN"
  type = list(object({
    vpn_gateway_interface           = number
    peer_external_gateway_interface = number
  }))
  default = [
    {
      vpn_gateway_interface           = 0
      peer_external_gateway_interface = 0
    },
    {
      vpn_gateway_interface           = 1
      peer_external_gateway_interface = 1
    }
  ]
}

# GCP VM Variables
variable "gcp_vm_name" {
  description = "Name of the GCP test VM"
  type        = string
  default     = "gcp-instance"
}

variable "gcp_vm_machine_type" {
  description = "Machine type for GCP VM"
  type        = string
  default     = "e2-micro"
}

variable "gcp_vm_zone" {
  description = "Zone for GCP VM"
  type        = string
  default     = "asia-south1-a"
}

variable "gcp_vm_startup_script" {
  description = "Startup script for GCP VM"
  type        = string
  default     = "sudo apt-get update; sudo apt-get install nginx -y"
}

variable "gcp_vm_image" {
  description = "Image for GCP VM"
  type        = string
  default     = "ubuntu-os-cloud/ubuntu-2004-focal-v20220712"
}

variable "gcp_vm_tags" {
  description = "Tags for GCP VM"
  type        = list(string)
  default     = ["gcp-instance"]
}

# -----------------------------------------------------------------------------
# Shared Variables
# -----------------------------------------------------------------------------
variable "vpn_shared_key" {
  description = "Shared secret for VPN tunnels (both Azure and GCP)"
  type        = string
  sensitive   = true
}

variable "custom_ipsec_policy" {
  description = "Custom IPsec policy for Azure VPN connections"
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
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "production"
    ManagedBy   = "Terraform"
    Project     = "Azure-GCP-HA-VPN"
  }
}