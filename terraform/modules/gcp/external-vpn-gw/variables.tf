variable "gateway_name" {
  description = "Name of the external VPN gateway"
  type        = string
}

variable "redundancy_type" {
  description = "Redundancy type (SINGLE_IP_INTERNALLY_REDUNDANT, TWO_IPS_REDUNDANCY, FOUR_IPS_REDUNDANCY)"
  type        = string
  default     = "TWO_IPS_REDUNDANCY"
}

variable "description" {
  description = "Description of the external gateway"
  type        = string
  default     = ""
}

variable "interfaces" {
  description = "List of external gateway interfaces"
  type = list(object({
    id         = number
    ip_address = string
  }))
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
  default     = null
}