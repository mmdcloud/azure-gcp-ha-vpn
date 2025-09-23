terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    # vault = {
    #   source  = "hashicorp/vault"
    #   version = "~> 4.0"
    # }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  subscription_id = "ac0192a4-f2ec-4c2e-bf7e-6e8a051fe856"
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_location
}

# provider "vault" {}