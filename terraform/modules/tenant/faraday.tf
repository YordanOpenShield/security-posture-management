locals {
  templates_dir = "${path.module}/templates"
  render_dir    = "${path.module}/_rendered"
}

resource "local_file" "install_faraday_sh" {
  content  = templatefile("${local.templates_dir}/install-faraday.sh.tftpl", {
    faraday_directory = var.faraday_directory
    faraday_version   = var.faraday_version
    faraday_password  = random_password.faraday_password.result
  })
  filename = "${local.render_dir}/install-faraday.sh"
}

resource "local_file" "install_nginx_sh" {
  content  = templatefile("${local.templates_dir}/install-nginx.sh.tftpl", {})
  filename = "${local.render_dir}/install-nginx.sh"
}

resource "local_file" "configure_faraday_nginx_sh" {
  content  = templatefile("${local.templates_dir}/configure-faraday-nginx.sh.tftpl", {
    faraday_host      = "faraday.${var.spm_subdomain}.${var.base_domain}"
    faraday_directory = var.faraday_directory
  })
  filename = "${local.render_dir}/configure-faraday-nginx.sh"
}

resource "null_resource" "provision_faraday_scripts" {
  provisioner "file" {
    source      = local.render_dir
    destination = "/tmp/scripts"

    connection {
      type        = "ssh"
      host        = hcloud_server.tenant_server.ipv4_address
      port        = 2222
      user        = var.provision_user
      private_key = tls_private_key.ssh_key.private_key_pem
      agent       = false
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/scripts/install-faraday.sh",
      "sudo chmod +x /tmp/scripts/install-nginx.sh",
      "sudo chmod +x /tmp/scripts/configure-faraday-nginx.sh",
      "sudo /tmp/scripts/install-faraday.sh ${var.faraday_version}",
      "sudo /tmp/scripts/install-nginx.sh",
      "sudo /tmp/scripts/configure-faraday-nginx.sh"
    ]

    connection {
      type        = "ssh"
      host        = hcloud_server.tenant_server.ipv4_address
      user        = var.provision_user
      private_key = tls_private_key.ssh_key.private_key_pem
      agent       = false
      timeout     = "10m"
    }
  }

    depends_on = [
        cloudflare_dns_record.faraday,
        local_file.install_faraday_sh,
        local_file.install_nginx_sh,
        local_file.configure_faraday_nginx_sh,
        random_password.faraday_password
    ]
}
