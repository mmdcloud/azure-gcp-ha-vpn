variable "bgp_addresses" {
  type = list(object({
    ip_configuration_name = string
    apipa_addresses       = list()
  }))
  default = [{
    ip_configuration_name = "public-ip-1"
    apipa_addresses       = ["169.254.21.10"]
    }, {
    ip_configuration_name = "public-ip-2"
    apipa_addresses       = ["169.254.21.14"]
  }]
}
