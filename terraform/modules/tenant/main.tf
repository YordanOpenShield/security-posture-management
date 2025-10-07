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

resource "kubernetes_persistent_volume_claim" "opensearch_pvc" {
  metadata {
    name      = "opensearch-data-${var.tenant}"
    namespace = kubernetes_namespace.tenant_ns.metadata[0].name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = var.opensearch_storage
      }
    }
  }
}

resource "kubernetes_deployment" "opensearch" {
  metadata {
    name      = "opensearch-${var.tenant}"
    namespace = kubernetes_namespace.tenant_ns.metadata[0].name
    labels = {
      app    = "opensearch"
      tenant = var.tenant
    }
  }
  spec {
    replicas = 1
    selector { match_labels = { app = "opensearch" } }
    template {
      metadata { labels = { app = "opensearch" } }
      spec {
        container {
          name  = "opensearch"
          image = var.opensearch_image
          env {
            name  = "discovery.type"
            value = "single-node"
          }
          env {
            name  = "OPENSEARCH_JAVA_OPTS"
            value = var.opensearch_java_opts
          }
          port { container_port = 9200 }
          resources {
            limits = var.opensearch_limits
            requests = var.opensearch_requests
          }
          volume_mount {
            mount_path = "/usr/share/opensearch/data"
            name       = "opensearch-data"
          }
        }
        volume {
          name = "opensearch-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.opensearch_pvc.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "opensearch_svc" {
  metadata {
    name      = "opensearch"
    namespace = kubernetes_namespace.tenant_ns.metadata[0].name
  }
  spec {
    selector = { app = "opensearch" }
    port {
      port        = 9200
      target_port = 9200
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_deployment" "opa" {
  metadata {
    name      = "opa-${var.tenant}"
    namespace = kubernetes_namespace.tenant_ns.metadata[0].name
    labels = { app = "opa" }
  }
  spec {
    replicas = 1
    selector { match_labels = { app = "opa" } }
    template {
      metadata { labels = { app = "opa" } }
      spec {
        container {
          name  = "opa"
          image = var.opa_image
          args  = ["run","--server","--addr=0.0.0.0:8181"]
          port { container_port = 8181 }
          resources {
            requests = var.opa_requests
            limits   = var.opa_limits
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "opa_svc" {
  metadata {
    name      = "opa"
    namespace = kubernetes_namespace.tenant_ns.metadata[0].name
  }
  spec {
    selector = { app = "opa" }
    port {
      port = 8181
      target_port = 8181
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_deployment" "faraday" {
  metadata {
    name      = "faraday-${var.tenant}"
    namespace = kubernetes_namespace.tenant_ns.metadata[0].name
    labels = { app = "faraday" }
  }
  spec {
    replicas = 1
    selector { match_labels = { app = "faraday" } }
    template {
      metadata { labels = { app = "faraday" } }
      spec {
        container {
          name  = "faraday"
          image = var.faraday_image
          image_pull_policy = "IfNotPresent"
          port { container_port = 5985 }
          resources {
            requests = var.faraday_requests
            limits   = var.faraday_limits
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "faraday_svc" {
  metadata {
    name      = "faraday"
    namespace = kubernetes_namespace.tenant_ns.metadata[0].name
  }
  spec {
    selector = { app = "faraday" }
    port {
      port = 5985
      target_port = 5985
    }
    type = "ClusterIP"
  }
}

# Optional Ingress to expose services via an Ingress controller (e.g. nginx)
resource "kubernetes_ingress_v1" "tenant_ingress" {
  count = 1

  metadata {
    name      = "${var.tenant}-ingress"
    namespace = kubernetes_namespace.tenant_ns.metadata[0].name
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
      # Use cert-manager annotation if TLS is desired and cert-manager is installed
      "cert-manager.io/cluster-issuer" = var.ingress_tls_secret != "" ? "letsencrypt-staging" : ""
    }
  }

  spec {
    rule {
      host = "${var.tenant}.${var.cluster_domain}"
      http {
        path {
          path     = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.faraday_svc.metadata[0].name
              port { number = 5985 }
            }
          }
        }
      }
    }

    tls {
      secret_name = var.ingress_tls_secret
      hosts = ["${var.tenant}.${var.cluster_domain}"]
    }
  }
}
