resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "hcloud_ssh_key" "ssh_key" {
  name       = "${var.name}-ssh-key"
  public_key = tls_private_key.ssh_key.public_key_openssh

  labels = {
    tenant   = var.name
    solution = "spm"
  }

  lifecycle {
    # Force regeneration of the SSH key pair if refresh_ssh_key is true
    replace_triggered_by = var.refresh_ssh_key ? [ timestamp() ] : []
  }
}