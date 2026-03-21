variable "vm_name" {
  description = "Name of the virtual machine"
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

variable "subnet_id" {
  description = "ID of the subnet where VM will be deployed"
  type        = string
}

variable "vm_size" {
  description = "Size of the virtual machine"
  type        = string
  default     = "Standard_B1s"
}

variable "admin_username" {
  description = "Administrator username"
  type        = string
  default     = "azureuser"
}

variable "admin_password" {
  description = "Administrator password (required if password auth is enabled)"
  type        = string
  sensitive   = true
  default     = null
}

variable "disable_password_authentication" {
  description = "Disable password authentication and use SSH keys"
  type        = bool
  default     = false
}

variable "ssh_public_key" {
  description = "SSH public key for authentication"
  type        = string
  default     = null
}

variable "create_public_ip" {
  description = "Create a public IP address for the VM"
  type        = bool
  default     = true
}

variable "create_nsg" {
  description = "Create a Network Security Group"
  type        = bool
  default     = true
}

variable "associate_nsg_to_subnet" {
  description = "Associate NSG to subnet instead of NIC"
  type        = bool
  default     = true
}

variable "nsg_rules" {
  description = "List of NSG security rules"
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
    }
  ]
}

variable "os_disk_caching" {
  description = "OS disk caching type"
  type        = string
  default     = "ReadWrite"
}

variable "os_disk_storage_account_type" {
  description = "OS disk storage account type"
  type        = string
  default     = "Standard_LRS"
}

variable "os_disk_size_gb" {
  description = "OS disk size in GB"
  type        = number
  default     = null
}

variable "image_publisher" {
  description = "Image publisher"
  type        = string
  default     = "Canonical"
}

variable "image_offer" {
  description = "Image offer"
  type        = string
  default     = "UbuntuServer"
}

variable "image_sku" {
  description = "Image SKU"
  type        = string
  default     = "18.04-LTS"
}

variable "image_version" {
  description = "Image version"
  type        = string
  default     = "latest"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}