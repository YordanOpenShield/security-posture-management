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

locals {
  cluster_name = "spm-${var.tenant}-cluster"
}