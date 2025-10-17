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

  # Prevent accidental deletion of SSH key on terraform destroy.
  # This ensures users keep access credentials even if the rest of the tenant
  # infrastructure is removed. To allow deletion deliberately, remove this
  # block or override with the -target option.
  lifecycle {
    precondition {
      condition = var.refresh_ssh_key == true
      error_message = "SSH key regeneration is required."
    }
  }
}