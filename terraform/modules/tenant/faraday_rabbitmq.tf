resource "kubernetes_service" "rabbitmq" {
  metadata {
    name      = "rabbitmq"
    namespace = kubernetes_namespace.tenant_ns.metadata[0].name
  }
  spec {
    selector = { app = "rabbitmq" }
    port {
      port        = 5672
      target_port = 5672
    }
  }
}

resource "kubernetes_persistent_volume_claim" "rabbitmq" {
  metadata {
    name      = "rabbitmq-data"
    namespace = kubernetes_namespace.tenant_ns.metadata[0].name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = { storage = "10Gi" }
    }
  }
}

resource "kubernetes_deployment" "rabbitmq" {
  metadata {
    name      = "rabbitmq"
    namespace = kubernetes_namespace.tenant_ns.metadata[0].name
  }

  spec {
    replicas = 1
    selector {
      match_labels = { app = "rabbitmq" }
    }

    template {
      metadata {
        labels = { app = "rabbitmq" }
      }

      spec {
        container {
          name  = "rabbitmq"
          image = "rabbitmq:3-management-alpine"

          port {
            container_port = 5672
          }

          env {
            name = "RABBITMQ_DEFAULT_USER"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.rabbitmq_auth.metadata[0].name
                key  = "RABBITMQ_DEFAULT_USER"
              }
            }
          }

          env {
            name = "RABBITMQ_DEFAULT_PASS"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.rabbitmq_auth.metadata[0].name
                key  = "RABBITMQ_DEFAULT_PASS"
              }
            }
          }

          volume_mount {
            name       = "rabbitmq-data"
            mount_path = "/var/lib/rabbitmq"
          }
        }

        volume {
          name = "rabbitmq-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.rabbitmq.metadata[0].name
          }
        }
      }
    }
  }
}