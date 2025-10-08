resource "kubernetes_ingress_class_v1" "nginx" {
  metadata {
    name = "nginx"
  }
  spec {
    controller = "k8s.io/ingress-nginx"
  }
}

resource "kubernetes_ingress_v1" "faraday" {
  metadata {
    name      = "faraday-ingress"
    namespace = kubernetes_namespace.tenant_ns.metadata[0].name
    annotations = {
      "kubernetes.io/ingress.class"                 = "nginx"
      "nginx.ingress.kubernetes.io/rewrite-target"  = "/"
      # Do not enforce SSL redirect during initial testing - expose Faraday over plain HTTP
      "nginx.ingress.kubernetes.io/ssl-redirect"    = "false"
      "nginx.ingress.kubernetes.io/proxy-body-size" = "50m"
      # Uncomment next line if using cert-manager
      # "cert-manager.io/cluster-issuer"              = "letsencrypt-prod"
    }
  }

  spec {
    rule {
      host = "${local.faraday_host}"
      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "faraday"
              port {
                number = 5985
              }
            }
          }
        }
      }
    }

    # No TLS configured: using plain HTTP for initial testing
  }
}
