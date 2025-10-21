resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "hcloud_ssh_key" "ssh_key" {
  name       = "${var.tenant_name}-ssh-key"
  public_key = tls_private_key.ssh_key.public_key_openssh

  labels = {
    tenant   = var.tenant_name
    solution = "spm"
  }
}