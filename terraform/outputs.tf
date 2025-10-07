output "cluster_name" {
  value = digitalocean_kubernetes_cluster.spm_cluster.name
}

output "cluster_id" {
  value = digitalocean_kubernetes_cluster.spm_cluster.id
}