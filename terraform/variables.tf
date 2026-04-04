variable "hcloud_token" {
  description = "Hetzner Cloud API token"
  type        = string
  sensitive   = true
}

variable "cloudflare_api_token" {
  description = "Cloudflare API token with DNS edit permissions"
  type        = string
  sensitive   = true
}

variable "ssh_public_key" {
  description = "SSH public key content for VPS access"
  type        = string
}

variable "server_name" {
  description = "Name of the Hetzner server"
  type        = string
  default     = "prod-01"
}

variable "server_type" {
  description = "Hetzner server type (e.g., cx22, cx32)"
  type        = string
  default     = "cpx32"
}

variable "server_location" {
  description = "Hetzner datacenter location"
  type        = string
  default     = "nbg1"
}

variable "server_image" {
  description = "OS image for the server"
  type        = string
  default     = "ubuntu-22.04"
}

variable "server_ip" {
  description = "Static IP of the existing server (used for DNS A records)"
  type        = string
  default     = "178.104.132.83"
}

variable "domains" {
  description = "Map of site names to their domain and Cloudflare zone ID"
  type = map(object({
    domain  = string
    zone_id = string
  }))
}
