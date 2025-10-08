resource "kubernetes_deployment" "opensearch_dashboards" {
  metadata {
    name      = "opensearch-dashboards"
    namespace = kubernetes_namespace.tenant_ns.metadata[0].name
    labels = {
      app = "opensearch-dashboards"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = { app = "opensearch-dashboards" }
    }

    template {
      metadata {
        labels = { app = "opensearch-dashboards" }
      }
      spec {
        container {
          name  = "opensearch-dashboards"
          image = var.opensearch_dashboards_image

          port {
            container_port = 5601
          }

          env {
            name  = "OPENSEARCH_HOSTS"
            value = "http://${kubernetes_service.opensearch.metadata[0].name}.${kubernetes_namespace.tenant_ns.metadata[0].name}.svc.cluster.local:9200"
          }

          env {
            name = "OPENSEARCH_USERNAME"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.opensearch_admin_auth.metadata[0].name
                key  = "OPENSEARCH_INITIAL_ADMIN_USERNAME"
              }
            }
          }

          env {
            name = "OPENSEARCH_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.opensearch_admin_auth.metadata[0].name
                key  = "OPENSEARCH_INITIAL_ADMIN_PASSWORD"
              }
            }
          }

          resources {
            requests = var.opensearch_dashboards_requests
            limits = var.opensearch_dashboards_limits
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "opensearch_dashboards" {
  metadata {
    name      = "opensearch-dashboards"
    namespace = kubernetes_namespace.tenant_ns.metadata[0].name
  }
  spec {
    selector = { app = "opensearch-dashboards" }
    port {
      port        = 5601
      target_port = 5601
    }
    type = "ClusterIP"
  }
}
