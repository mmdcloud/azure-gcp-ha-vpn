# ---------------------------
# Azure Configuration
# ---------------------------
resource "azurerm_resource_group" "rg" {
  name     = "azure-vpn"
  location = "centralindia"
}

module "azure_vnet" {
  source              = "./modules/azure/vnet"
  vnet_name           = "azure-vnet"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnets = [
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

resource "azurerm_public_ip" "public_ip_1" {
  name                = "azure-vm-public-ip-1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  zones               = ["1"]
}

resource "azurerm_public_ip" "public_ip_2" {
  name                = "azure-vm-public-ip-2"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  zones               = ["1"]
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
    name                          = "ip-config-1"
    public_ip_address_id          = azurerm_public_ip.public_ip_1.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = module.azure_vnet.subnets[1].id
  }

  ip_configuration {
    name                          = "ip-config-2"
    public_ip_address_id          = azurerm_public_ip.public_ip_2.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = module.azure_vnet.subnets[1].id
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

  gateway_address = google_compute_ha_vpn_gateway.gcp_vpn_gateway.vpn_interfaces[0].ip_address

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

  gateway_address = google_compute_ha_vpn_gateway.gcp_vpn_gateway.vpn_interfaces[1].ip_address

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
# VPC Creation
module "gcp_vpc" {
  source                  = "./modules/gcp/network/vpc"
  auto_create_subnetworks = false
  vpc_name                = "gcp-vpc"
  routing_mode            = "REGIONAL"
}

# Subnets Creation
module "gcp_vpc_public_subnets" {
  source                   = "./modules/gcp/network/subnet"
  name                     = "vpn-public-subnet"
  subnets                  = var.gcp_public_subnets
  vpc_id                   = module.gcp_vpc.vpc_id
  private_ip_google_access = false
  location                 = var.gcp_location
}

module "gcp_vpc_private_subnets" {
  source                   = "./modules/gcp/network/subnet"
  name                     = "vpn-private-subnet"
  subnets                  = var.gcp_private_subnets
  vpc_id                   = module.gcp_vpc.vpc_id
  private_ip_google_access = true
  location                 = var.gcp_location
}

resource "google_compute_firewall" "allow_ssh" {
  name      = "allow-ssh"
  network   = module.gcp_vpc.vpc_name
  direction = "INGRESS"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["gcp-instance"]
}

# Create a HA VPN gateway in GCP
resource "google_compute_ha_vpn_gateway" "gcp_vpn_gateway" {
  name               = "gcp-vpn-gateway"
  network            = module.gcp_vpc.vpc_id
  gateway_ip_version = "IPV4"
  region             = var.gcp_location
}

# Create a cloud router for BGP (optional)
resource "google_compute_router" "gcp_router" {
  name    = "gcp-vpn-router"
  network = module.gcp_vpc.vpc_id
  region  = var.gcp_location

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
  region                          = var.gcp_location
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
  region                          = var.gcp_location
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
  region          = var.gcp_location
  peer_ip_address = "169.254.21.10"
  peer_asn        = 65515
  # advertised_route_priority = 100
  interface = google_compute_router_interface.gcp_interface1.name
}

resource "google_compute_router_peer" "gcp_bgp_peer2" {
  name            = "gcp-bgp-peer2"
  router          = google_compute_router.gcp_router.name
  region          = var.gcp_location
  peer_ip_address = "169.254.21.14"
  peer_asn        = 65515
  # advertised_route_priority = 100
  interface = google_compute_router_interface.gcp_interface2.name
}

resource "google_compute_router_interface" "gcp_interface1" {
  name       = "gcp-interface1"
  router     = google_compute_router.gcp_router.name
  region     = var.gcp_location
  ip_range   = "169.254.21.9/30"
  vpn_tunnel = google_compute_vpn_tunnel.gcp_tunnel1.name
}

resource "google_compute_router_interface" "gcp_interface2" {
  name       = "gcp-interface2"
  router     = google_compute_router.gcp_router.name
  region     = var.gcp_location
  ip_range   = "169.254.21.13/30"
  vpn_tunnel = google_compute_vpn_tunnel.gcp_tunnel2.name
}

# ---------------------------
# Test Instances
# ---------------------------

# Azure VM
resource "azurerm_public_ip" "azure_vm_public_ip" {
  name                = "azure-vm-public-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "azure_vm_nic" {
  name                = "azure-vm-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.azure_vnet.subnets[0].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.azure_vm_public_ip.id
  }
}

# Network Security Group
resource "azurerm_network_security_group" "nsg" {
  name                = "azure-vm-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
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
}

# Associate NSG with Subnet
resource "azurerm_subnet_network_security_group_association" "nsg_assoc" {
  subnet_id                 = module.azure_vnet.subnets[0].id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_linux_virtual_machine" "azure_vm" {
  name                            = "azure-vm"
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  size                            = "Standard_B1s"
  disable_password_authentication = false
  admin_username                  = "madmax"
  network_interface_ids = [
    azurerm_network_interface.azure_vm_nic.id,
  ]

  admin_password = "Mohitdixit12345!"

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

# GCP VM
resource "google_compute_address" "gcp_vm_ip" {
  name = "gcp-vm-public-ip"
}

# Instance 1
module "instance1" {
  source                    = "./modules/gcp/compute"
  name                      = "gcp-instance"
  machine_type              = "e2-micro"
  zone                      = "asia-south1-a"
  metadata_startup_script   = "sudo apt-get update; sudo apt-get install nginx -y"
  deletion_protection       = false
  allow_stopping_for_update = true
  image                     = "ubuntu-os-cloud/ubuntu-2004-focal-v20220712"
  network_interfaces = [
    {
      network    = module.gcp_vpc.vpc_id
      subnetwork = module.gcp_vpc_public_subnets.subnets[0].id
      access_configs = [
        {
          nat_ip = google_compute_address.gcp_vm_ip.address
        }
      ]
    }
  ]
  tags = ["gcp-instance"]
}