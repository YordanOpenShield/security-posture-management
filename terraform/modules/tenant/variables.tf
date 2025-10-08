# Tenant-specific

variable "tenant" {
  type = string
}

# Images (can be overridden via root variables)

variable "opensearch_image" {
  type    = string
  default = "opensearchproject/opensearch:2.9.0"
}

variable "opa_image" {
  type    = string
  default = "openpolicyagent/opa:0.54.0"
}

variable "faraday_image" {
  type    = string
  default = "faradaysec/faraday:latest"
}

# Resource allocations and storage

variable "opensearch_storage" {
  type    = string
  default = "20Gi"
}

variable "quota_hard" {
  type = map(string)
  default = {
    "requests.cpu"    = "4"
    "requests.memory" = "8Gi"
    "limits.cpu"      = "8"
    "limits.memory"   = "16Gi"
    "pods"            = "10"
    "persistentvolumeclaims" = "5"
  }
}

variable "limit_default" {
  type = map(string)
  default = {
    cpu    = "250m"
    memory = "256Mi"
  }
}

variable "limit_default_request" {
  type = map(string)
  default = {
    cpu    = "100m"
    memory = "128Mi"
  }
}

variable "limit_max" {
  type = map(string)
  default = {
    cpu    = "2"
    memory = "4Gi"
  }
}

variable "limit_min" {
  type = map(string)
  default = {
    cpu    = "50m"
    memory = "64Mi"
  }
}

variable "opensearch_java_opts" {
  type    = string
  default = "-Xms2g -Xmx2g"
}

variable "opensearch_limits" {
  type = map(string)
  default = {
    cpu = "1"
    memory = "2Gi"
  }
}

variable "opensearch_requests" {
  type = map(string)
  default = {
    cpu = "500m"
    memory = "1Gi"
  }
}

variable "opa_limits" {
  type = map(string)
  default = {
    cpu = "250m"
    memory = "256Mi"
  }
}

variable "opa_requests" {
  type = map(string)
  default = {
    cpu = "50m"
    memory = "64Mi"
  }
}

variable "faraday_limits" {
  type = map(string)
  default = {
    cpu = "1"
    memory = "1Gi"
  }
}

variable "faraday_requests" {
  type = map(string)
  default = {
    cpu = "500m"
    memory = "512Mi"
  }
}

# Cluster-specific

variable "cluster_domain" {
  type        = string
  description = "The domain name of the cluster"
}

# Locals

locals {
    tenant_domain   = "${var.tenant}.${var.cluster_domain}"
    faraday_host    = "faraday.${local.tenant_domain}"
    opensearch_host = "opensearch.${local.tenant_domain}"
}