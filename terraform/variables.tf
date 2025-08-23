variable "bgp_addresses" {
  type = list(object({
    ip_configuration_name = string
    apipa_addresses       = list(string)
  }))
  default = [{
    ip_configuration_name = "public-ip-1"
    apipa_addresses       = ["169.254.21.10"]
    }, {
    ip_configuration_name = "public-ip-2"
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