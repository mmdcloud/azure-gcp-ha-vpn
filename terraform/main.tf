# ---------------------------
# Azure Configuration
# ---------------------------
resource "azurerm_resource_group" "rg" {
  name     = "azure-vpn"
  location = "Central INDIA"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "gateway_subnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.1.1.0/24"]
}

resource "azurerm_public_ip" "public_ip_1" {
  name                = "public-ip-1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method = "Dynamic"
}

resource "azurerm_public_ip" "public_ip_2" {
  name                = "public-ip-2"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "vng" {
  name                = "vnet-gateway"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  type          = "Vpn"
  vpn_type      = "RouteBased"
  sku           = "VpnGw2AZ"
  generation    = "Generation2"
  active_active = true
  enable_bgp    = true

  ip_configuration {
    name                          = "public-ip-1"
    public_ip_address_id          = azurerm_public_ip.public_ip_1.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gateway_subnet.id
  }

  ip_configuration {
    name                          = "public-ip-2"
    public_ip_address_id          = azurerm_public_ip.public_ip_1.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gateway_subnet.id
  }

  bgp_settings {
    asn = 65515
    peering_addresses {
      ip_configuration_name = "bgp-ip"
      apipa_addresses       = ["169.254.21.10", "169.254.21.14"]
    }
  }
}

# Local Network Gateway
resource "azurerm_local_network_gateway" "local_gw_1" {
  name                = "local-gw-1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  gateway_address = "203.0.113.10"  

  bgp_settings {
    asn = 65001
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

  gateway_address = "203.0.113.10"

  bgp_settings {
    asn = 65001
    bgp_peering_address = "169.254.21.13"
  }

  tags = {
    environment = "production"
  }
}

resource "azurerm_virtual_network_gateway_connection" "connection1" {
  name                = "connection1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vng.id
  local_network_gateway_id   = azurerm_local_network_gateway.local_gw_1.id

  shared_key = "Mohitdixit12345!"
}

resource "azurerm_virtual_network_gateway_connection" "connection2" {
  name                = "connection2"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vng.id
  local_network_gateway_id   = azurerm_local_network_gateway.local_gw_1.id

  shared_key = "Mohitdixit12345!"
}

# ---------------------------
# GCP Configuration
# ---------------------------
