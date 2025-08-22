variable "bgp_addresses" {
    type = list(object({
        ip_configuration_name =  string
        apipa_addresses =  list()
    }))
}