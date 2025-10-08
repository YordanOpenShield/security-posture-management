output "namespace" {
  value = kubernetes_namespace.tenant_ns.metadata[0].name
}

output "faraday_host" {
  value = local.faraday_host
}

output "opensearch_host" {
  value = local.opensearch_host
}