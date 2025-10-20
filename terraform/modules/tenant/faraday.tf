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
    faraday_host      = "faraday.${var.name}.${var.spm_subdomain}.${var.base_domain}"
    faraday_directory = var.faraday_directory
  })
  filename = "${local.render_dir}/configure-faraday-nginx.sh"
}

resource "local_file" "configure_faraday_sh" {
  content  = templatefile("${local.templates_dir}/configure-faraday.sh.tftpl", {
    faraday_user     = local.faraday_user
    faraday_password = random_password.faraday_password.result
    faraday_url      = "https://faraday.${var.name}.${var.spm_subdomain}.${var.base_domain}"
  })
  filename = "${local.render_dir}/configure-faraday.sh"
}

resource "null_resource" "provision_faraday_scripts" {
    triggers = {
        always_run = timestamp()
    }

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
        "export DEBIAN_FRONTEND=noninteractive",
        # wait for cloud-init (if present) and for systemd jobs to settle
        "until sudo cloud-init status | grep -q 'done'; do sleep 1; done || true",
        "while systemctl list-jobs | grep -q systemd-sysctl && [ $timeout -gt 0 ]; do sleep 1; timeout=$((timeout-1)); done || true",
        # make log dir
        "sudo mkdir -p /tmp/provision-logs && sudo chown ${var.provision_user}:${var.provision_user} /tmp/provision-logs",
        # ensure package index is fresh
        "sudo apt update -y",
        # wait for postgres and redis services if they're expected from packages
        "for svc in postgresql redis; do tries=0; until sudo systemctl is-active --quiet $svc || [ $tries -ge 30 ]; do echo 'Waiting for' $svc; sleep 2; tries=$((tries+1)); done; done",
        # make scripts executable
        "sudo chmod +x /tmp/scripts/*.sh",

        # run each script under bash -x and capture logs; on failure print the tail and exit non-zero
        "sudo bash -x /tmp/scripts/install-faraday.sh >> /tmp/provision-logs/install-faraday.log 2>&1 || { sudo tail -n 200 /tmp/provision-logs/install-faraday.log; exit 1; }",
        "sudo bash -x /tmp/scripts/install-nginx.sh >> /tmp/provision-logs/install-nginx.log 2>&1 || { sudo tail -n 200 /tmp/provision-logs/install-nginx.log; exit 1; }",
        "sudo bash -x /tmp/scripts/configure-faraday-nginx.sh >> /tmp/provision-logs/configure-faraday-nginx.log 2>&1 || { sudo tail -n 200 /tmp/provision-logs/configure-faraday-nginx.log; exit 1; }",
        "sudo bash -x /tmp/scripts/configure-faraday.sh >> /tmp/provision-logs/configure-faraday.log 2>&1 || { sudo tail -n 200 /tmp/provision-logs/configure-faraday.log; exit 1; }",

        # show summary of logs and cleanup
        "echo '--- provision logs (last 200 lines) ---'",
        "sudo tail -n 200 /tmp/provision-logs/install-faraday.log || true",
        ]

        connection {
        type        = "ssh"
        host        = hcloud_server.tenant_server.ipv4_address
        port        = 2222
        user        = var.provision_user
        private_key = tls_private_key.ssh_key.private_key_pem
        agent       = false
        timeout     = "30m"
        }
    }

    depends_on = [
        cloudflare_dns_record.faraday,
        local_file.install_faraday_sh,
        local_file.install_nginx_sh,
        local_file.configure_faraday_nginx_sh,
        random_password.faraday_password,
        hcloud_server.tenant_server,
        hcloud_volume.tenant_volume
    ]
}
