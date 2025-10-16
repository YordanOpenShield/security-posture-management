resource "hcloud_server" "tenant_server" {
  name        = "spm-tenant-${var.name}"
  image       = var.server_image
  server_type = local.chosen_server_type
  ssh_keys    = [hcloud_ssh_key.ssh_key.id]

  labels = {
    tenant   = var.name
    solution = "spm"
  }

  # TODO: Harden SSH further
  user_data = <<-EOF
    #cloud-config
    packages:
      - sudo
      - curl
      - ca-certificates
      - apt-transport-https
      - fail2ban
      - ufw
      - postgresql
      - redis
    package_update: true
    package_upgrade: true
    users:
      - name: ${local.ansible_user}
        sudo: ALL=(ALL) NOPASSWD:ALL
        shell: /bin/bash
        ssh-authorized-keys:
          - ${tls_private_key.ssh_key.public_key_openssh}
    write_files:
      - path: /etc/ssh/sshd_config.d/ssh-hardening.conf
        content: |
          PermitRootLogin no
          PasswordAuthentication yes
          Port 2222
          KbdInteractiveAuthentication no
          ChallengeResponseAuthentication no
          MaxAuthTries 2
          AllowTcpForwarding no
          X11Forwarding no
          AllowAgentForwarding no
          AuthorizedKeysFile .ssh/authorized_keys
          AllowUsers ${local.ansible_user}
    runcmd:
      - printf "[sshd]\nenabled = true\nport = ssh, 2222\nbanaction = iptables-multiport" > /etc/fail2ban/jail.local
      - systemctl enable fail2ban
      - ufw allow 2222
      - ufw allow http
      - ufw allow https
      - ufw allow 5985
      - ufw enable
      - reboot
    EOF

  depends_on = [
    hcloud_ssh_key.ssh_key
  ]
}

resource "hcloud_volume" "tenant_volume" {
  name        = "spm-tenant-${var.name}-volume"
  size        = var.volume_size
  format      = "ext4"
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