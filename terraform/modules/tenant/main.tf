resource "hcloud_server" "tenant_server" {
  name        = "spm-tenant-${var.name}"
  image       = var.server_image
  server_type = local.chosen_server_type
  # location    = var.server_location
  ssh_keys    = [hcloud_ssh_key.ssh_key.id]

  labels = {
    tenant   = var.name
    solution = "spm"
  }

  depends_on = [
    hcloud_ssh_key.ssh_key
  ]
}

resource "hcloud_volume" "tenant_volume" {
  name        = "spm-tenant-${var.name}-volume"
  size        = var.volume_size
  format      = "ext4"
  # location    = var.server_location
  server_id   = hcloud_server.tenant_server.id
  automount   = true

  labels = {
    tenant = var.name
    solution = "spm"
  }

  depends_on = [
    hcloud_server.tenant_server
  ]
}