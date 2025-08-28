output "azure_instance_public_ip" {
  description = "The public IP address of the Azure instance"
  value       = azurerm_public_ip.azure_vm_public_ip.ip_address
}

output "gcp_instance_public_ip" {
  description = "The public IP address of the GCP instance"
  value       = google_compute_address.gcp_vm_ip.address
}