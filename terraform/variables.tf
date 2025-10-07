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

variable "opensearch_image" {
  description = "OpenSearch image"
  type        = string
  default     = "opensearchproject/opensearch:2.9.0"
}

variable "opa_image" {
  description = "OPA image"
  type        = string
  default     = "openpolicyagent/opa:0.54.0"
}

variable "faraday_image" {
  description = "Faraday image"
  type        = string
  default     = "faradaysec/faraday:latest"
}

locals {
  cluster_name = "spm-${var.tenant}-cluster"
  cluster_domain = "spm.openshield.io"
}