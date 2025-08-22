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

resource "azurerm_virtual_network_gateway" "vng" {
  name                = "vnet-gateway"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  type     = "Vpn"           
  vpn_type = "RouteBased"
  sku      = "VpnGw2AZ"      

  active_active = true
  enable_bgp    = true
  
  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.gw_pip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gateway_subnet.id
  }
  bgp_settings {
    
  }
  
}

# ---------------------------
# GCP Configuration
# ---------------------------