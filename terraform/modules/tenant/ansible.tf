resource "ansible_playbook" "tenant_configure" {
  playbook = "./ansible/playbooks/tenant.yml"
  replayable = true

  connection {
    type        = "ssh"
    host        = hcloud_server.tenant_server.ipv4_address
    user        = locals.ansible_user
    private_key = tls_private_key.ssh_key.private_key_pem
  }

  extra_vars = {
    tenant_name = var.name
    pg_user     = local.postgres_user
    pg_password = random_password.pg_password.result
    rmq_user    = local.rabbitmq_user
    rmq_password = random_password.rmq_password.result
  }

  depends_on = [hcloud_server.tenant_server, hcloud_ssh_key.ssh_key]
}
