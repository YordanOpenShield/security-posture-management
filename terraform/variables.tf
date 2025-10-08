variable "digitalocean_token" {
  type        = string
  description = "DigitalOcean API token"
}

variable "tenant" {
  type        = string
  description = "Tenant identifier"
}

variable "region" {
  description = "DigitalOcean region for droplets"
  type        = string
  default     = "nyc3"
}

variable "droplet_size" {
  description = "DigitalOcean droplet size slug"
  type        = string
  default     = "s-2vcpu-4gb"
}
variable "min_nodes" {
  description = "Minimum nodes in the DO Kubernetes node pool"
  type        = number
  default     = 1
}

variable "max_nodes" {
  description = "Maximum nodes in the DO Kubernetes node pool"
  type        = number
  default     = 5
}

variable "cluster_name" {
  type        = string
  description = "Kubernetes cluster name"
  default     = "spm-cluster"
}

variable "cluster_domain" {
  type    = string
  default = "spm.openshield.io"
}

variable "k8s_version" {
  description = "Kubernetes version (leave empty for latest)"
  type        = string
  default     = ""
}

variable "cloudflare_token" {
  type        = string
  description = "Cloudflare API token with DNS edit permissions"
  default     = ""
}

variable "cloudflare_zone" {
  type        = string
  description = "Cloudflare zone (root domain) where records will be created, e.g. example.com"
  default     = "openshield.io"
}

variable "cloudflare_proxied" {
  type        = bool
  description = "Whether the Cloudflare record should be proxied (orange cloud). Default false for now."
  default     = false
}