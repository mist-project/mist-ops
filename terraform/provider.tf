terraform {
  required_version = ">=1.12.2"

  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc9"
    }
  }
}

# ---- PROXMOX VARIABLES ----
variable "PROXMOX_URL" {
  type        = string
  description = "Proxmox API URL."
}

variable "PROXMOX_TOKEN_ID" {
  type        = string
  sensitive   = true
  description = "Proxmox API token ID in the format 'user@realm!tokenid'."
}

variable "PROXMOX_TOKEN_SECRET" {
  type        = string
  sensitive   = true
  description = "Proxmox API token secret."
}

provider "proxmox" {
  pm_api_url          = var.PROXMOX_URL
  pm_api_token_id     = var.PROXMOX_TOKEN_ID
  pm_api_token_secret = var.PROXMOX_TOKEN_SECRET

  pm_tls_insecure = true
}

# ---- BACKEND PG DEV VARIABLES ----
variable "MIST_BACKEND_PG_DEV_USERNAME" {
  type        = string
  sensitive   = false
  description = "Username for the mist backend PostgreSQL development VM."
}

variable "MIST_BACKEND_PG_DEV_PASSWORD" {
  type        = string
  sensitive   = true
  description = "Password for the mist backend PostgreSQL development VM."
}

variable "MIST_BACKEND_PG_DEV_SSH_PUBKEY" {
  type        = string
  sensitive   = true
  description = "SSH public key for the mist backend PostgreSQL development VM."
}
