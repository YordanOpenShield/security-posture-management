resource "kubernetes_persistent_volume_claim" "opensearch_data" {
  metadata {
    name      = "opensearch-data"
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

resource "kubernetes_service" "opensearch" {
  metadata {
    name      = "opensearch"
    namespace = kubernetes_namespace.tenant_ns.metadata[0].name
  }
  spec {
    selector = {
      app = "opensearch"
    }
    port {
      name        = "http"
      port        = 9200
      target_port = 9200
    }
    port {
      name        = "transport"
      port        = 9300
      target_port = 9300
    }
  }
}

resource "kubernetes_stateful_set" "opensearch" {
  metadata {
    name      = "opensearch"
    namespace = kubernetes_namespace.tenant_ns.metadata[0].name
    labels = {
      app = "opensearch"
    }
  }

  spec {
    service_name = kubernetes_service.opensearch.metadata[0].name
    replicas     = 1

    selector {
      match_labels = {
        app = "opensearch"
      }
    }

    template {
      metadata {
        labels = {
          app = "opensearch"
        }
      }

      spec {
        # Pod-level security context: run OpenSearch as UID 1000 and set fsGroup so the
        # kubelet ensures the volume has group write for that GID. This helps when PV
        # mounts contain root-owned directories like lost+found.
        security_context {
          run_as_user = 1000
          fs_group     = 1000
        }

        # Optional init container to set sysctl (if allowed by node policy)
        init_container {
          name  = "init-sysctl"
          image = "busybox:1.36"
          # Make sysctl tolerant: some managed clusters do not allow sysctl
          # changes from containers. Append || true so the init step succeeds
          # even if the sysctl command fails.
          command = ["sh", "-c", "sysctl -w vm.max_map_count=262144 || true"]
          security_context {
            privileged = true
          }
        }

        # Ensure the data directory is owned by the OpenSearch user (uid:1000).
        # Some storage implementations mount a filesystem with root-owned dirs
        # (eg. lost+found). This init container runs as root and fixes ownership so
        # OpenSearch can write into the data path.
        init_container {
          name  = "chown-data"
          image = "busybox:1.36"
          # Run this init container as root so it can chown the mounted volume.
          command = ["sh", "-c", "chown -R 1000:1000 /usr/share/opensearch/data || true"]
          security_context {
            run_as_user = 0
          }
          volume_mount {
            name       = "opensearch-data"
            mount_path = "/usr/share/opensearch/data"
          }
        }

        container {
          name  = "opensearch"
          image = "opensearchproject/opensearch:2.13.0"

          port {
            container_port = 9200
            name           = "http"
          }
          port {
            container_port = 9300
            name           = "transport"
          }

          env {
            name  = "discovery.type"
            value = "single-node"
          }

          env {
            name  = "plugins.security.disabled"
            value = "false"
          }

          env {
            name  = "OPENSEARCH_JAVA_OPTS"
            value = var.opensearch_java_opts
          }

          env {
            name = "OPENSEARCH_INITIAL_ADMIN_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.opensearch_admin_auth.metadata[0].name
                key  = "OPENSEARCH_INITIAL_ADMIN_PASSWORD"
              }
            }
          }

          volume_mount {
            name       = "opensearch-data"
            mount_path = "/usr/share/opensearch/data"
          }

          resources {
            requests = var.opensearch_requests
            limits = var.opensearch_limits
          }

          readiness_probe {
            http_get {
              path = "/"
              port = "http"
            }
            initial_delay_seconds = 30
            timeout_seconds        = 5
          }

          liveness_probe {
            http_get {
              path = "/"
              port = "http"
            }
            initial_delay_seconds = 60
            timeout_seconds        = 5
          }
        }

        volume {
          name = "opensearch-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.opensearch_data.metadata[0].name
          }
        }
      }
    }
  }
}