resource "local_file" "install_faraday_sh" {
  content  = templatefile("${local.templates_dir}/install-faraday.sh.tftpl", {
    faraday_directory = local.faraday_dir
    faraday_version   = var.faraday_version
    faraday_password  = local.faraday_password
  })
  filename = "${local.render_dir}/install-faraday.sh"
}

resource "local_file" "install_nginx_sh" {
  content  = templatefile("${local.templates_dir}/install-nginx.sh.tftpl", {})
  filename = "${local.render_dir}/install-nginx.sh"
}

resource "local_file" "configure_faraday_nginx_sh" {
  content  = templatefile("${local.templates_dir}/configure-faraday-nginx.sh.tftpl", {
    faraday_host      = var.faraday_host
    faraday_directory = local.faraday_dir
  })
  filename = "${local.render_dir}/configure-faraday-nginx.sh"
}

resource "local_file" "configure_faraday_sh" {
  content  = templatefile("${local.templates_dir}/configure-faraday.sh.tftpl", {
    faraday_user     = local.faraday_user
    faraday_password = local.faraday_password
    faraday_url      = "https://${var.faraday_host}"
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
        host        = var.faraday_host
        port        = 2222
        user        = var.provision_user
        private_key = var.provision_private_key
        agent       = false
        }
    }

    provisioner "remote-exec" {
        inline = [
        "export DEBIAN_FRONTEND=noninteractive",
        # wait for cloud-init (if present) and for systemd jobs to settle
        "while sudo cloud-init status | grep -vq 'done'; do sleep 1 && echo 'Waiting for cloud-init...'; done || true",
        "while sudo systemctl list-jobs | grep -q systemd-sysctl; do sleep 1 && echo 'Waiting for systemd-sysctl...'; done || true",
        # make log dir
        "sudo mkdir -p /tmp/provision-logs && sudo chown ${var.provision_user}:${var.provision_user} /tmp/provision-logs",
        # ensure package index is fresh
        "sudo apt update -y",
        # wait for postgres and redis services if they're expected from packages
        "for svc in postgresql redis; do until sudo systemctl is-active --quiet $svc; do echo 'Waiting for' $svc; sleep 2; done; done",
        # make scripts executable
        "sudo chmod +x /tmp/scripts/*.sh",

        # run each script under bash -x and capture logs; on failure print the tail and exit non-zero
        "sudo bash -x /tmp/scripts/install-faraday.sh >> /tmp/provision-logs/install-faraday.log 2>&1 || { sudo tail -n 200 /tmp/provision-logs/install-faraday.log; exit 1; }",
        "sudo bash -x /tmp/scripts/install-nginx.sh >> /tmp/provision-logs/install-nginx.log 2>&1 || { sudo tail -n 200 /tmp/provision-logs/install-nginx.log; exit 1; }",
        "sudo bash -x /tmp/scripts/configure-faraday-nginx.sh >> /tmp/provision-logs/configure-faraday-nginx.log 2>&1 || { sudo tail -n 200 /tmp/provision-logs/configure-faraday-nginx.log; exit 1; }",
        "sudo bash -x /tmp/scripts/configure-faraday.sh >> /tmp/provision-logs/configure-faraday.log 2>&1 || { sudo tail -n 200 /tmp/provision-logs/configure-faraday.log; exit 1; }",

        # clean up scripts
        "sudo rm -rf /tmp/scripts",
        ]

        connection {
        type        = "ssh"
        host        = var.faraday_host
        port        = 2222
        user        = var.provision_user
        private_key = var.provision_private_key
        agent       = false
        timeout     = "30m"
        }
    }

    depends_on = [
        local_file.install_faraday_sh,
        local_file.install_nginx_sh,
        local_file.configure_faraday_nginx_sh,
    ]
}

# TODO: Migrate Faraday provisioning to Ansible