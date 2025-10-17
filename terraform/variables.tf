variable "hetzner_token" {
  description = "API token for Hetzner Cloud"
  type        = string
  sensitive   = true
  default     = null
}

variable "cloudflare_token" {
  description = "API token for Cloudflare (used by tenant module)"
  type        = string
  sensitive   = true
  default     = null
}

# == Input Variables ==

variable "tenant" {
  description = "Name of the tenant"
  type        = string
}

variable "refresh_ssh_key" {
  description = "If true, forces regeneration of the SSH key pair for the tenant"
  type        = bool
  default     = false
}