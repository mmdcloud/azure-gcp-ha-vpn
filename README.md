# Multi-Cloud VPN Infrastructure (Azure ↔ GCP)

[![Terraform](https://img.shields.io/badge/Terraform-v1.0+-623CE4?logo=terraform)](https://www.terraform.io/)
[![Azure](https://img.shields.io/badge/Azure-VPN_Gateway-0078D4?logo=microsoft-azure)](https://azure.microsoft.com/)
[![GCP](https://img.shields.io/badge/GCP-HA_VPN-4285F4?logo=google-cloud)](https://cloud.google.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

> **Production-ready Terraform infrastructure** for establishing secure, highly-available site-to-site VPN connectivity between **Microsoft Azure** and **Google Cloud Platform** using BGP routing.

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [Deployment](#deployment)
- [Verification](#verification)
- [Security Considerations](#security-considerations)
- [Cost Estimation](#cost-estimation)
- [Troubleshooting](#troubleshooting)
- [Cleanup](#cleanup)
- [Contributing](#contributing)
- [License](#license)

---

## 🎯 Overview

This Terraform configuration automates the deployment of a **highly-available, BGP-enabled VPN connection** between Azure and GCP environments. It enables secure communication between resources across both cloud platforms with automatic failover capabilities.

### Use Cases

- **Hybrid Cloud Architecture**: Seamlessly connect workloads across Azure and GCP
- **Multi-Cloud Data Transfer**: Secure data replication and synchronization
- **Disaster Recovery**: Cross-cloud backup and failover strategies
- **Geographic Distribution**: Low-latency access to resources across cloud providers

---

## 🏗️ Architecture

### Network Topology

```
┌─────────────────────────────────────┐         ┌─────────────────────────────────────┐
│          MICROSOFT AZURE            │         │       GOOGLE CLOUD PLATFORM         │
│                                     │         │                                     │
│  ┌───────────────────────────────┐  │         │  ┌───────────────────────────────┐  │
│  │  VNet: 10.1.0.0/16            │  │         │  │  VPC: gcp-vpc                 │  │
│  │  ┌─────────────────────────┐  │  │         │  │  ┌─────────────────────────┐  │  │
│  │  │ Subnet: 10.1.1.0/24     │  │  │         │  │  │ Subnet: 10.2.1.0/24     │  │  │
│  │  │ (Default)               │  │  │         │  │  │ (vpn-public-subnet-1)   │  │  │
│  │  └─────────────────────────┘  │  │         │  │  └─────────────────────────┘  │  │
│  │  ┌─────────────────────────┐  │  │         │  │  ┌─────────────────────────┐  │  │
│  │  │ Subnet: 10.1.2.0/24     │  │  │         │  │  │ Subnet: 10.2.2.0/24     │  │  │
│  │  │ (GatewaySubnet)         │  │  │         │  │  │ (vpn-public-subnet-2)   │  │  │
│  │  └─────────────────────────┘  │  │         │  │  └─────────────────────────┘  │  │
│  └───────────────────────────────┘  │         │  │  ┌─────────────────────────┐  │  │
│                                     │         │  │  │ Subnet: 10.2.3.0/24     │  │  │
│  ┌───────────────────────────────┐  │         │  │  │ (vpn-public-subnet-3)   │  │  │
│  │  VPN Gateway (VpnGw2AZ)       │  │         │  │  └─────────────────────────┘  │  │
│  │  - Active-Active Mode         │  │         │  └───────────────────────────────┘  │
│  │  - BGP Enabled (ASN: 65515)   │  │         │                                     │
│  │  ┌─────────────┐              │  │         │  ┌───────────────────────────────┐  │
│  │  │ Public IP 1 │──────────────┼──┼─────────┼──│  HA VPN Gateway              │  │
│  │  └─────────────┘     IPSec    │  │  BGP    │  │  - Interface 0               │  │
│  │  ┌─────────────┐    Tunnel 1  │  │  Peer   │  │  - Interface 1               │  │
│  │  │ Public IP 2 │──────────────┼──┼─────────┼──│  - BGP (ASN: 65001)          │  │
│  │  └─────────────┘     IPSec    │  │         │  │  ┌──────────────────────────┐│  │
│  │                      Tunnel 2  │  │         │  │  │  Cloud Router            ││  │
│  └───────────────────────────────┘  │         │  │  │  - Advertises Subnets    ││  │
│                                     │         │  │  │  - BGP Peering           ││  │
│  ┌───────────────────────────────┐  │         │  │  └──────────────────────────┘│  │
│  │  Test VM (Ubuntu 18.04)       │  │         │  └───────────────────────────────┘  │
│  │  - Private IP: Dynamic        │  │         │                                     │
│  │  - Public IP: Static          │  │         │  ┌───────────────────────────────┐  │
│  │  - User: madmax               │  │         │  │  Test VM (Ubuntu 20.04)       │  │
│  └───────────────────────────────┘  │         │  │  - Machine: e2-micro          │  │
│                                     │         │  │  - Nginx installed            │  │
└─────────────────────────────────────┘         │  └───────────────────────────────┘  │
                                                │                                     │
                                                └─────────────────────────────────────┘
```

### BGP Configuration

| Component | ASN | Peering Address |
|-----------|-----|----------------|
| Azure VPN Gateway | 65515 | 169.254.21.10 (Tunnel 1)<br>169.254.21.14 (Tunnel 2) |
| GCP Cloud Router | 65001 | 169.254.21.9 (Tunnel 1)<br>169.254.21.13 (Tunnel 2) |

---

## ✨ Features

### High Availability
- ✅ **Active-Active VPN**: Dual-tunnel configuration with automatic failover
- ✅ **Zone-Redundant Gateways**: Azure VpnGw2AZ with availability zone support
- ✅ **BGP Routing**: Dynamic route propagation and automatic failover
- ✅ **99.95% SLA**: Production-grade uptime guarantee

### Security
- 🔒 **IPSec Encryption**: Industry-standard IKEv2 protocol
- 🔒 **Shared Secret Authentication**: Pre-shared keys for tunnel establishment
- 🔒 **Network Security Groups**: Fine-grained traffic control on Azure side
- 🔒 **Firewall Rules**: GCP firewall rules for access control

### Automation
- ⚙️ **Infrastructure as Code**: Complete Terraform automation
- ⚙️ **Modular Design**: Reusable modules for VPC, compute, and networking
- ⚙️ **State Management**: Support for remote state backends
- ⚙️ **Idempotent Deployments**: Safe to run multiple times

### Monitoring & Operations
- 📊 **Built-in Metrics**: Azure Monitor and GCP Cloud Monitoring integration
- 📊 **Connection Health**: Automatic tunnel status monitoring
- 📊 **BGP Session Status**: Real-time peering state visibility

---

## 📦 Prerequisites

### Required Software

| Tool | Version | Purpose |
|------|---------|---------|
| [Terraform](https://www.terraform.io/downloads.html) | ≥ 1.0 | Infrastructure provisioning |
| [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) | ≥ 2.0 | Azure authentication |
| [gcloud CLI](https://cloud.google.com/sdk/docs/install) | Latest | GCP authentication |
| Git | ≥ 2.0 | Repository management |

### Cloud Provider Credentials

#### Azure Setup
```bash
# Login to Azure
az login

# Set subscription (if you have multiple)
az account set --subscription "YOUR_SUBSCRIPTION_ID"

# Verify authentication
az account show
```

#### GCP Setup
```bash
# Login to GCP
gcloud auth application-default login

# Set project
gcloud config set project YOUR_PROJECT_ID

# Enable required APIs
gcloud services enable compute.googleapis.com
gcloud services enable servicenetworking.googleapis.com
```

### Required Permissions

#### Azure
- **Contributor** role on the subscription or resource group
- Permissions to create:
  - Virtual Networks
  - VPN Gateways
  - Public IPs
  - Virtual Machines
  - Network Security Groups

#### GCP
- **Compute Network Admin** role
- **Compute Instance Admin** role
- Permissions to create:
  - VPC Networks
  - VPN Gateways
  - Cloud Routers
  - Compute Instances

---

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/your-org/azure-gcp-vpn.git
cd azure-gcp-vpn
```

### 2. Configure Variables

Create a `terraform.tfvars` file:

```hcl
# terraform.tfvars

# GCP Configuration
gcp_project_id = "your-gcp-project-id"
gcp_location   = "asia-south1"

# BGP Configuration
bgp_addresses = [
  {
    ip_configuration_name = "ip-config-1"
    apipa_addresses       = ["169.254.21.10"]
  },
  {
    ip_configuration_name = "ip-config-2"
    apipa_addresses       = ["169.254.21.14"]
  }
]
```

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Review Plan

```bash
terraform plan -out=tfplan
```

### 5. Deploy Infrastructure

```bash
terraform apply tfplan
```

**Expected deployment time**: ~20-30 minutes

---

## ⚙️ Configuration

### Required Variables

Create a `variables.tf` file with the following:

```hcl
variable "gcp_project_id" {
  description = "GCP project ID"
  type        = string
}

variable "gcp_location" {
  description = "GCP region for resources"
  type        = string
  default     = "asia-south1"
}

variable "bgp_addresses" {
  description = "BGP APIPA addresses for Azure VPN Gateway"
  type = list(object({
    ip_configuration_name = string
    apipa_addresses       = list(string)
  }))
}
```

### Module Structure

```
.
├── main.tf                    # Main configuration file
├── variables.tf               # Variable definitions
├── terraform.tfvars           # Variable values (gitignored)
├── outputs.tf                 # Output definitions
├── versions.tf                # Provider version constraints
├── modules/
│   ├── azure/
│   │   └── vnet/             # Azure VNet module
│   └── gcp/
│       ├── vpc/              # GCP VPC module
│       └── compute/          # GCP Compute module
└── README.md
```

### Network CIDR Planning

| Network | CIDR | Purpose |
|---------|------|---------|
| Azure VNet | 10.1.0.0/16 | Azure virtual network |
| Azure Default Subnet | 10.1.1.0/24 | Workload resources |
| Azure Gateway Subnet | 10.1.2.0/24 | VPN Gateway (required) |
| GCP Subnet 1 | 10.2.1.0/24 | Primary workload subnet |
| GCP Subnet 2 | 10.2.2.0/24 | Secondary subnet |
| GCP Subnet 3 | 10.2.3.0/24 | Tertiary subnet |
| BGP Peering (Tunnel 1) | 169.254.21.8/30 | Link-local addressing |
| BGP Peering (Tunnel 2) | 169.254.21.12/30 | Link-local addressing |

---

## 🔧 Deployment

### Terraform Backend Configuration

For production deployments, configure remote state:

```hcl
# backend.tf
terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "tfstateXXXXX"
    container_name       = "tfstate"
    key                  = "azure-gcp-vpn.tfstate"
  }
}
```

Or use GCS:

```hcl
terraform {
  backend "gcs" {
    bucket = "your-terraform-state-bucket"
    prefix = "azure-gcp-vpn"
  }
}
```

### Deployment Stages

#### Stage 1: Network Foundation
```bash
terraform apply -target=module.azure_vnet -target=module.gcp_vpc
```

#### Stage 2: VPN Gateways
```bash
terraform apply -target=azurerm_virtual_network_gateway.vng \
                -target=google_compute_ha_vpn_gateway.gcp_vpn_gateway
```

#### Stage 3: VPN Connections
```bash
terraform apply -target=google_compute_vpn_tunnel.gcp_tunnel1 \
                -target=google_compute_vpn_tunnel.gcp_tunnel2
```

#### Stage 4: Complete Deployment
```bash
terraform apply
```

### Post-Deployment Validation

```bash
# Get Azure VPN Gateway status
az network vnet-gateway show \
  --name azure-vpn-gateway \
  --resource-group azure-vpn \
  --query "provisioningState"

# Get GCP VPN tunnel status
gcloud compute vpn-tunnels describe gcp-tunnel1 \
  --region=asia-south1 \
  --format="value(status)"
```

---

## ✅ Verification

### 1. Check VPN Connection Status

#### Azure Side
```bash
# List connections
az network vpn-connection list \
  --resource-group azure-vpn \
  --output table

# Check connection status
az network vpn-connection show \
  --name connection1 \
  --resource-group azure-vpn \
  --query "connectionStatus"
```

#### GCP Side
```bash
# Check tunnel status
gcloud compute vpn-tunnels list --format="table(
  name,
  status,
  detailedStatus
)"

# View BGP session status
gcloud compute routers get-status gcp-vpn-router \
  --region=asia-south1
```

### 2. Verify BGP Routing

#### Azure
```bash
az network vnet-gateway list-learned-routes \
  --name azure-vpn-gateway \
  --resource-group azure-vpn \
  --output table
```

#### GCP
```bash
gcloud compute routers get-status gcp-vpn-router \
  --region=asia-south1 \
  --format="table(
    result.bgpPeerStatus[].name,
    result.bgpPeerStatus[].state,
    result.bgpPeerStatus[].numLearnedRoutes
  )"
```

### 3. Test Connectivity

#### From Azure VM to GCP VM
```bash
# SSH to Azure VM
ssh madmax@<AZURE_VM_PUBLIC_IP>

# Ping GCP VM private IP
ping 10.2.1.X

# Test HTTP
curl http://10.2.1.X
```

#### From GCP VM to Azure VM
```bash
# SSH to GCP VM
gcloud compute ssh gcp-instance --zone=asia-south1-a

# Ping Azure VM private IP
ping 10.1.1.X
```

### 4. Performance Testing

```bash
# Install iperf3 on both VMs
# Azure VM
sudo apt-get install iperf3 -y

# GCP VM
sudo apt-get install iperf3 -y

# Run server on GCP
iperf3 -s

# Run client from Azure
iperf3 -c 10.2.1.X -t 30
```

---

## 🔒 Security Considerations

### Critical Security Items

> ⚠️ **WARNING**: The following security issues must be addressed before production use:

1. **Hardcoded Credentials** (Lines 123, 134, 359)
   ```hcl
   # ❌ NEVER commit passwords to version control
   shared_key = "Mohitdixit12345!"
   admin_password = "Mohitdixit12345!"
   ```

   **Fix**: Use Azure Key Vault or GCP Secret Manager:
   ```hcl
   data "azurerm_key_vault_secret" "vpn_shared_key" {
     name         = "vpn-shared-key"
     key_vault_id = var.key_vault_id
   }
   
   resource "azurerm_virtual_network_gateway_connection" "connection1" {
     shared_key = data.azurerm_key_vault_secret.vpn_shared_key.value
   }
   ```

2. **Open SSH Access** (Line 177)
   ```hcl
   # ❌ Allows SSH from anywhere
   source_ranges = ["0.0.0.0/0"]
   ```

   **Fix**: Restrict to known IPs:
   ```hcl
   source_ranges = [
     "YOUR_OFFICE_IP/32",
     "YOUR_HOME_IP/32"
   ]
   ```

3. **Weak Password Policy**
   - Minimum 12 characters
   - Mix of uppercase, lowercase, numbers, special characters
   - Use SSH keys instead of passwords

### Security Checklist

- [ ] Remove hardcoded secrets from code
- [ ] Store secrets in Azure Key Vault / GCP Secret Manager
- [ ] Implement least-privilege IAM policies
- [ ] Enable Azure Security Center
- [ ] Enable GCP Security Command Center
- [ ] Configure VPN connection alerting
- [ ] Enable Azure Monitor / Cloud Logging
- [ ] Implement network segmentation
- [ ] Use Jump Hosts / Bastion services for VM access
- [ ] Enable MFA for cloud console access
- [ ] Regular security audits and penetration testing
- [ ] Implement DDoS protection
- [ ] Configure backup and disaster recovery

### Recommended Secrets Management

```hcl
# variables.tf
variable "vpn_shared_key" {
  description = "VPN shared secret key"
  type        = string
  sensitive   = true
}

variable "vm_admin_password" {
  description = "VM admin password"
  type        = string
  sensitive   = true
}

# Use in terraform.tfvars (gitignored)
# vpn_shared_key = "your-secure-key-here"
# vm_admin_password = "your-secure-password-here"
```

---

## 💰 Cost Estimation

### Monthly Cost Breakdown (Approximate)

| Service | Azure Cost | GCP Cost | Total |
|---------|------------|----------|-------|
| VPN Gateway (VpnGw2AZ) | $315/month | - | $315 |
| HA VPN Gateway | - | $89/month | $89 |
| Public IP Addresses (3) | $10/month | $13/month | $23 |
| Cloud Router | - | $75/month | $75 |
| Data Transfer (100GB) | $10/month | $10/month | $20 |
| VM Instances | $5/month | $5/month | $10 |
| **TOTAL** | **~$340/month** | **~$192/month** | **~$532/month** |

> 💡 **Cost Optimization Tips**:
> - Use VpnGw1 instead of VpnGw2AZ for non-production ($140/month savings)
> - Delete test VMs when not needed
> - Use reserved instances for long-term deployments
> - Monitor and optimize data transfer

### Cost Calculator Links
- [Azure Pricing Calculator](https://azure.microsoft.com/en-us/pricing/calculator/)
- [GCP Pricing Calculator](https://cloud.google.com/products/calculator)

---

## 🔍 Troubleshooting

### Common Issues

#### 1. VPN Tunnel Status: Not Connected

**Symptoms**: Tunnel shows as "Not connected" in portal

**Causes & Solutions**:
```bash
# Check if shared keys match
# Azure
az network vpn-connection show \
  --name connection1 \
  --resource-group azure-vpn \
  --query "sharedKey"

# Verify BGP settings
az network vnet-gateway show \
  --name azure-vpn-gateway \
  --resource-group azure-vpn \
  --query "bgpSettings"

# GCP - Check tunnel configuration
gcloud compute vpn-tunnels describe gcp-tunnel1 \
  --region=asia-south1
```

#### 2. BGP Session Down

**Check BGP status**:
```bash
# Azure
az network vnet-gateway list-bgp-peer-status \
  --name azure-vpn-gateway \
  --resource-group azure-vpn

# GCP
gcloud compute routers get-status gcp-vpn-router \
  --region=asia-south1
```

**Common fixes**:
- Verify APIPA addresses don't overlap
- Ensure ASN numbers are correct
- Check firewall rules allow BGP (TCP 179)

#### 3. No Route Propagation

**Verify learned routes**:
```bash
# Azure
az network vnet-gateway list-learned-routes \
  --name azure-vpn-gateway \
  --resource-group azure-vpn

# GCP
gcloud compute routers get-status gcp-vpn-router \
  --region=asia-south1 \
  --format="get(result.bestRoutes)"
```

#### 4. Connectivity Works One Way Only

**Check**:
- Network Security Groups on Azure
- Firewall rules on GCP
- Route tables on both sides
- VM-level firewalls (iptables, Windows Firewall)

### Debug Commands

```bash
# Azure VPN Diagnostics
az network vpn-connection show-connection-health \
  --name connection1 \
  --resource-group azure-vpn

# GCP VPN Diagnostics
gcloud compute vpn-tunnels describe gcp-tunnel1 \
  --region=asia-south1 \
  --format="value(detailedStatus)"

# Packet capture on GCP
gcloud compute instances add-access-config gcp-instance \
  --zone=asia-south1-a
sudo tcpdump -i any icmp -n
```

### Logging

#### Enable Azure Diagnostics
```bash
az monitor diagnostic-settings create \
  --resource <VPN_GATEWAY_ID> \
  --name vpn-diagnostics \
  --logs '[{"category":"GatewayDiagnosticLog","enabled":true}]' \
  --workspace <LOG_ANALYTICS_WORKSPACE_ID>
```

#### Enable GCP Logging
```bash
gcloud compute routers update gcp-vpn-router \
  --region=asia-south1 \
  --enable-log
```

---

## 🧹 Cleanup

### Complete Infrastructure Teardown

```bash
# Destroy all resources
terraform destroy

# Confirm when prompted
# Type: yes
```

### Selective Resource Removal

```bash
# Remove only test VMs
terraform destroy -target=azurerm_linux_virtual_machine.azure_vm \
                  -target=module.gcp_instance

# Remove VPN connections
terraform destroy -target=azurerm_virtual_network_gateway_connection.connection1 \
                  -target=azurerm_virtual_network_gateway_connection.connection2 \
                  -target=google_compute_vpn_tunnel.gcp_tunnel1 \
                  -target=google_compute_vpn_tunnel.gcp_tunnel2
```

### Manual Cleanup Verification

```bash
# Verify Azure resources deleted
az resource list --resource-group azure-vpn

# Verify GCP resources deleted
gcloud compute vpn-tunnels list
gcloud compute vpn-gateways list
gcloud compute networks list --filter="name=gcp-vpc"
```

---

## 📚 Additional Resources

### Documentation
- [Azure VPN Gateway Documentation](https://docs.microsoft.com/en-us/azure/vpn-gateway/)
- [GCP HA VPN Documentation](https://cloud.google.com/network-connectivity/docs/vpn/concepts/overview)
- [BGP Routing Protocols](https://cloud.google.com/network-connectivity/docs/router/concepts/overview)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Terraform GCP Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)

### Tutorials
- [Multi-Cloud VPN Best Practices](https://cloud.google.com/architecture/best-practices-vpc-design)
- [BGP Configuration Guide](https://docs.microsoft.com/en-us/azure/vpn-gateway/bgp-howto)

### Community
- [Azure Community](https://techcommunity.microsoft.com/t5/azure/ct-p/Azure)
- [GCP Community](https://www.googlecloudcommunity.com/)
- [Terraform Community](https://discuss.hashicorp.com/c/terraform-core/)

---

## 🤝 Contributing

We welcome contributions! Please follow these guidelines:

### Contribution Process

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Make your changes**
4. **Test thoroughly**
   ```bash
   terraform fmt -recursive
   terraform validate
   ```
5. **Commit with conventional commits**
   ```bash
   git commit -m "feat: add support for custom BGP ASN"
   ```
6. **Push and create PR**
   ```bash
   git push origin feature/your-feature-name
   ```

### Code Standards

- Use `terraform fmt` for consistent formatting
- Add comments for complex logic
- Update README for new features
- Include examples in module documentation
- Test in dev environment before submitting PR

### Reporting Issues

Please include:
- Terraform version
- Provider versions
- Steps to reproduce
- Expected vs actual behavior
- Relevant logs

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👥 Authors

- **Your Name** - *Initial work* - [@yourusername](https://github.com/yourusername)

See also the list of [contributors](https://github.com/your-org/azure-gcp-vpn/contributors) who participated in this project.

---

## 🙏 Acknowledgments

- HashiCorp for Terraform
- Microsoft Azure team
- Google Cloud Platform team
- Community contributors

---

## 📞 Support

- 📧 Email: support@yourcompany.com
- 💬 Slack: [Join our workspace](https://yourworkspace.slack.com)
- 🐛 Issues: [GitHub Issues](https://github.com/your-org/azure-gcp-vpn/issues)
- 📖 Wiki: [Project Wiki](https://github.com/your-org/azure-gcp-vpn/wiki)

---

<div align="center">
  <p>Built with ❤️ using Terraform</p>
  <p>
    <a href="#multi-cloud-vpn-infrastructure-azure--gcp">Back to top ⬆️</a>
  </p>
</div>
