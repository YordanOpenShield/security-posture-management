# Tenant-specific

variable "tenant" {
  type = string
}

# Images (can be overridden via root variables)

variable "opensearch_image" {
  type    = string
  default = "opensearchproject/opensearch:latest"
}

variable "opensearch_dashboards_image" {
  type    = string
  default = "opensearchproject/opensearch-dashboards:2.13.0"
}

variable "faraday_image" {
  type    = string
  default = "faradaysec/faraday:latest"
}

variable "postgres_image" {
  type    = string
  default = "postgres:16-alpine"
}

variable "rabbitmq_image" {
  type    = string
  default = "rabbitmq:3-management"
}

variable "redis_image" {
  type    = string
  default = "redis:6.2-alpine"
}

# Resource allocations and storage

variable "quota_hard" {
  type = map(string)
  default = {
    "requests.cpu"    = "4"
    "requests.memory" = "8Gi"
    "limits.cpu"      = "8"
    "limits.memory"   = "16Gi"
    "pods"            = "20"
    "persistentvolumeclaims" = "10"
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
    memory = "32Mi"
  }
}

variable "opensearch_java_opts" {
  type    = string
  default = "-Xms1g -Xmx1g"
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

variable "opensearch_storage" {
  type    = string
  default = "20Gi"
}

variable "opensearch_dashboards_limits" {
  type = map(string)
  default = {
    cpu = "500m"
    memory = "512Mi"
  }
}

variable "opensearch_dashboards_requests" {
  type = map(string)
  default = {
    cpu = "200m"
    memory = "256Mi"
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

variable "postgres_storage" {
  type    = string
  default = "20Gi"
}

variable "redis_storage" {
  type    = string
  default = "10Gi"
}

variable "redis_limits" {
  type = map(string)
  default = {
    cpu = "500m"
    memory = "512Mi"
  }
}

variable "redis_requests" {
  type = map(string)
  default = {
    cpu = "200m"
    memory = "256Mi"
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