resource "kubernetes_service" "redis" {
  metadata {
    name      = "redis"
    namespace = kubernetes_namespace.tenant_ns.metadata[0].name
  }
  spec {
    selector = { app = "redis" }
    port {
      port        = 6379
      target_port = 6379
      protocol    = "TCP"
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_deployment" "redis" {
  metadata {
    name      = "redis"
    namespace = kubernetes_namespace.tenant_ns.metadata[0].name
    labels = { app = "redis" }
  }

  spec {
    replicas = 1
    selector {
      match_labels = { app = "redis" }
    }

    template {
      metadata {
        labels = { app = "redis" }
      }

      spec {
        container {
          name  = "redis"
          image = var.redis_image
          image_pull_policy = "IfNotPresent"
          port {
            container_port = 6379
          }
          resources {
            requests = var.redis_requests
            limits = var.redis_limits
          }
        }
      }
    }
  }
}