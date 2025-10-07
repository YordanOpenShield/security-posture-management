output "kubeconfig" {
  description = "Kubeconfig to access the created cluster (base64 encoded)"
  value       = digitalocean_kubernetes_cluster.spm_cluster.kube_config[0].raw_kube_config
}

output "cluster_name" {
  value = digitalocean_kubernetes_cluster.spm_cluster.name
}