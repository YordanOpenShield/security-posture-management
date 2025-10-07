output "namespace" {
  value = kubernetes_namespace.tenant_ns.metadata[0].name
}

output "opensearch_service" {
  value = kubernetes_service.opensearch_svc.metadata[0].name
}

output "opa_service" {
  value = kubernetes_service.opa_svc.metadata[0].name
}

output "faraday_service" {
  value = kubernetes_service.faraday_svc.metadata[0].name
}

output "ingress_hostname" {
  value = var.ingress_hostname
}

output "ingress_tls_secret" {
  value = var.ingress_tls_secret
}
