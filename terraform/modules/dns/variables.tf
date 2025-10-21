variable "cloudflare_token" {
    description = "API token for Cloudflare (used by dns module)"
    type        = string
    sensitive   = true
}

variable "tenant_name" {
    description = "Name of the tenant (used by dns module)"
    type        = string
}

variable "tenant_host" {
    description = "IPv4 address of the tenant's server"
    type        = string
}

variable "base_domain" {
    description = "The base domain for DNS records"
    type        = string
}

variable "spm_subdomain" {
    description = "The subdomain under which tenant DNS records will be created"
    type        = string
    default     = "spm"
}

variable "faraday_subdomain" {
    description = "The subdomain for Faraday service"
    type        = string
    default     = "faraday"
}