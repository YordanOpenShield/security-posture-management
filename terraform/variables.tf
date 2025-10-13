variable "hetzner_token" {
  description = "API token for Hetzner Cloud"
  type        = string
}

# == Input Variables ==

variable "tenant" {
  description = "Name of the tenant"
  type        = string
}

variable "tenant_location" {
  description = "Location for the tenant's resources"
  type        = string
  default     = null
}