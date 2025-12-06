terraform {
  # Terraform version requirement
  required_version = ">= 1.10"

  # Provider requirements
  required_providers {
    # Libvirt Provider
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.9.1"
    }

    # Random Provider
    random = {
      source = "hashicorp/random"
    }

    # Time Provider
    time = {
      source = "hashicorp/time"
    }

  }

  # Configure remote state storage
  backend "consul" {
    address = "127.0.0.1:8500"
    scheme  = "http"
    path    = "opentofu/${local.hostname}/state"
  }

} # end of terraform block

provider "libvirt" {
  uri = "qemu:///system"
}

# Create a random ID to avoid name collisions
resource "random_id" "id" {
  byte_length = 4
}

# End of provider.tf
