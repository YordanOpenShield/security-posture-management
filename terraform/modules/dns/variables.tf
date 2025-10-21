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

variable "faraday_host" {
    description = "Fully qualified domain name for the Faraday instance"
    type        = string
}

variable "base_domain" {
    description = "Base domain for DNS records"
    type        = string
}