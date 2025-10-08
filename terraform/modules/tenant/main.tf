resource "kubernetes_namespace" "tenant_ns" {
  metadata {
    name = var.tenant
    labels = {
      tenant = var.tenant
    }
  }
}

# ResourceQuota
resource "kubernetes_resource_quota" "tenant_quota" {
  metadata {
    name      = "${var.tenant}-quota"
    namespace = kubernetes_namespace.tenant_ns.metadata[0].name
  }
  spec {
    hard = var.quota_hard
  }
}

# LimitRange
resource "kubernetes_limit_range" "tenant_limits" {
  metadata {
    name      = "${var.tenant}-limits"
    namespace = kubernetes_namespace.tenant_ns.metadata[0].name
  }
  spec {
    limit {
      type = "Container"
      default = var.limit_default
      default_request = var.limit_default_request
      max = var.limit_max
      min = var.limit_min
    }
  }
}