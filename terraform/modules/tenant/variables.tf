variable "tenant" {
  type = string
}

variable "cluster_domain" {
  type    = string
  default = "spm.openshield.io"
}

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

variable "opensearch_storage" {
  type    = string
  default = "10Gi"
}

variable "quota_hard" {
  type = map(string)
  default = {
    "requests.cpu"    = "2"
    "requests.memory" = "4Gi"
    "limits.cpu"      = "4"
    "limits.memory"   = "8Gi"
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
  default = "-Xms512m -Xmx512m"
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
    memory = "2Gi"
  }
}

variable "faraday_requests" {
  type = map(string)
  default = {
    cpu = "100m"
    memory = "128Mi"
  }
}

variable "ingress_tls_secret" {
  type    = string
  default = "verystrongsecret"
}
